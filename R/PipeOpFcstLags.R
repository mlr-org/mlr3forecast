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
#' At predict time, lags are computed from the task's full backend (i.e. including rows outside
#' `row_roles$use`), then joined onto the active rows. Used inside [RecursiveForecaster], where the
#' forecaster writes each step's prediction into the combined task's target column between steps so
#' lag features for the next step reflect the freshly predicted value.
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
          tags = c("train", "predict"),
          custom_check = crate(function(x) check_integerish(x, lower = 1L, any.missing = FALSE, min.len = 1L))
        )
      )
      param_set$set_values(lags = 1L)

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        feature_types = c("numeric", "integer", "Date", "factor"),
        tags = "fcst"
      )
      self$properties = union(self$properties, "fcst_iterative")
    }
  ),

  private = list(
    .train_task = function(task) {
      pv = self$param_set$get_values(tags = "train")
      lags = pv$lags
      target = task$target_names
      col_roles = task$col_roles
      key_cols = col_roles$key
      order_cols = col_roles$order

      before = task$feature_names
      dt = task$data(cols = c(target, key_cols, order_cols))
      set(dt, j = target, value = as.numeric(dt[[target]]))
      lag_cols = sprintf("%s_lag_%i", target, lags)
      if (length(key_cols) > 0L) {
        setorderv(dt, c(key_cols, order_cols))
        dt[, (lag_cols) := shift(get(target), lags), by = key_cols]
      } else {
        setorderv(dt, order_cols)
        set(dt, j = lag_cols, value = shift(dt[[target]], lags))
      }

      active = task$data(cols = c(key_cols, order_cols))
      set(dt, j = target, value = NULL)
      active_lags = dt[active, on = c(key_cols, order_cols)][, lag_cols, with = FALSE]
      out = task$select(task$feature_names)$cbind(active_lags)
      fcst_drop_incomplete(out, before, key_cols)
    },

    .predict_task = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      lags = pv$lags
      target = task$target_names
      col_roles = task$col_roles
      key_cols = col_roles$key
      order_cols = col_roles$order

      full = task$backend$data(rows = task$backend$rownames, cols = c(target, key_cols, order_cols))
      set(full, j = target, value = as.numeric(full[[target]]))
      lag_cols = sprintf("%s_lag_%i", target, lags)
      if (length(key_cols) > 0L) {
        setorderv(full, c(key_cols, order_cols))
        full[, (lag_cols) := shift(get(target), lags), by = key_cols]
      } else {
        setorderv(full, order_cols)
        set(full, j = lag_cols, value = shift(full[[target]], lags))
      }

      active = task$data(cols = c(key_cols, order_cols))
      set(full, j = target, value = NULL)
      active_lags = full[active, on = c(key_cols, order_cols)][, lag_cols, with = FALSE]
      task$select(task$feature_names)$cbind(active_lags)
    }
  )
)

#' @include zzz.R
register_po("fcst.lags", PipeOpFcstLags)
