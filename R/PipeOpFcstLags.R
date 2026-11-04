#' @title Create Lags of Target Variable
#' @name mlr_pipeops_fcst.lags
#'
#' @description
#' Creates lagged versions of the target variable as new feature columns.
#'
#' At train time the first rows of each series have no history for the requested lags. These
#' incomplete rows are dropped (the autoregressive-fit convention), so the base learner never sees
#' `NA` lags. A keyed series shorter than the largest lag is dropped entirely, with a warning.
#'
#' At predict time lags are computed from the full series history,
#' using the lags stored in the state at train time.
#'
#' Like every PipeOp with the `"fcst_iterative"` property, it implements `$shift()` and `$lookback`,
#' which move its features further into the past and report how much history they need.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreproc],
#' as well as the following parameters:
#' * `lags` :: `integer()`\cr
#'   The lags to create.
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' po = po("fcst.lags", lags = 1:3)
#' new_task = po$train(list(task))[[1L]]
#' new_task$head()
PipeOpFcstLags = R6Class(
  "PipeOpFcstLags",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.lags"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.lags", param_vals = list()) {
      param_set = ps(
        lags = p_uty(
          init = 1L,
          tags = "train",
          custom_check = crate(function(x) {
            check_integerish(x, lower = 1L, any.missing = FALSE, min.len = 1L, unique = TRUE)
          })
        )
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        can_subset_cols = FALSE,
        tags = "fcst"
      )
      self$properties = union(self$properties, "fcst_iterative")
    },

    #' @description
    #' Shifts the features `k` steps further into the past by adding `k` to every lag.
    #' Shifting by `h - 1` makes the features for horizon `h` use only values observed at the forecast origin.
    #' @param k (`integer(1)`)\cr
    #'   Number of steps to shift by.
    #' @return `self` (invisibly).
    shift = function(k) {
      k = assert_count(k, coerce = TRUE)
      self$param_set$values$lags = as.integer(self$param_set$values$lags) + k
      invisible(self)
    }
  ),

  active = list(
    #' @field lookback (`integer(1)`)\cr
    #' Number of past observations of a series the features need, i.e., the largest lag.
    #' Read-only.
    lookback = function(rhs) {
      assert_ro_binding(rhs)
      as.integer(max(self$param_set$values$lags))
    }
  ),

  private = list(
    .train_task = function(task) {
      pk = task$backend$primary_key
      dt = task$backend$data(
        rows = task$row_ids,
        cols = c(pk, task$target_names, task$col_roles$key, task$col_roles$order)
      )
      lags = self$param_set$get_values(tags = "train")$lags
      self$state = list(lags = lags)
      lag_cols = private$.lags(task, dt, lags)
      kept = fcst_drop_incomplete(dt, lag_cols, task$col_roles$key)
      task$filter(kept[[pk]])$cbind(kept[, c(pk, lag_cols), with = FALSE])
    },

    .predict_task = function(task) {
      key_cols = task$col_roles$key
      order_cols = task$col_roles$order
      full = task$backend$data(rows = task$backend$rownames, cols = c(task$target_names, key_cols, order_cols))
      lag_cols = private$.lags(task, full, self$state$lags)
      active = task$data(cols = c(key_cols, order_cols))
      active_lags = full[active, on = c(key_cols, order_cols), lag_cols, with = FALSE]
      task$cbind(active_lags)
    },

    .lags = function(task, dt, lags) {
      target = task$target_names
      key_cols = task$col_roles$key
      set(dt, j = target, value = as.numeric(dt[[target]]))
      lag_cols = sprintf("%s_lag_%i", target, lags)
      setorderv(dt, c(key_cols, task$col_roles$order))
      dt[,
        (lag_cols) := shift(target, lags),
        by = key_cols,
        env = list(target = target, lags = lags, key_cols = I(key_cols))
      ]
      lag_cols
    }
  )
)

#' @include zzz.R
register_po("fcst.lags", PipeOpFcstLags)
