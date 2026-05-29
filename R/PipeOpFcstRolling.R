#' @title Create Rolling Window Features of Target Variable
#' @name mlr_pipeops_fcst.rolling
#'
#' @description
#' Creates rolling-window summary statistics of the target variable as new feature columns.
#' The window ends at position `t - lag` (exclusive of the current and `lag - 1` most recent
#' values) and has size `window_size`.
#'
#' At predict time, rolling features are computed from the task's full backend (i.e. including
#' rows outside `row_roles$use`), then joined onto the active rows. Used inside
#' [RecursiveForecaster], where the forecaster writes each step's prediction into the combined
#' task's target column between steps so rolling features for the next step reflect the freshly
#' predicted value.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreproc],
#' as well as the following parameters:
#' * `funs` :: `character()`\cr
#'   Aggregation functions. Subset of `c("mean", "median", "sd", "min", "max", "sum")`. Default `"mean"`.
#' * `window_sizes` :: `integer()`\cr
#'   Window sizes. Every combination of `funs` and `window_sizes` produces one output column. Default `3L`.
#' * `lag` :: `integer(1)`\cr
#'   Minimum lag before the window starts. Must be `>= 1` to avoid leakage. Default `1L`.
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' po = po("fcst.rolling", funs = c("mean", "sd"), window_sizes = c(3L, 12L))
#' new_task = po$train(list(task))[[1L]]
#' new_task$head()
PipeOpFcstRolling = R6Class(
  "PipeOpFcstRolling",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.rolling"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.rolling", param_vals = list()) {
      param_set = ps(
        funs = p_uty(
          tags = c("train", "predict"),
          custom_check = function(x) {
            check_subset(x, choices = c("mean", "median", "sd", "min", "max", "sum"), empty.ok = FALSE)
          }
        ),
        window_sizes = p_uty(
          tags = c("train", "predict"),
          custom_check = function(x) check_integerish(x, lower = 1L, any.missing = FALSE, min.len = 1L)
        ),
        lag = p_int(1L, tags = c("train", "predict"))
      )
      param_set$set_values(funs = "mean", window_sizes = 3L, lag = 1L)

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
      target = task$target_names
      col_roles = task$col_roles
      key_cols = col_roles$key
      order_cols = col_roles$order

      dt = task$data(cols = c(target, key_cols, order_cols))
      roll_spec = private$.roll_spec(target)
      if (length(key_cols) > 0L) {
        setorderv(dt, c(key_cols, order_cols))
        dt[, (roll_spec$cols) := fcst_rolls(get(target), roll_spec), by = key_cols]
      } else {
        setorderv(dt, order_cols)
        set(dt, j = roll_spec$cols, value = fcst_rolls(dt[[target]], roll_spec))
      }
      task$select(task$feature_names)$cbind(dt[, roll_spec$cols, with = FALSE])
    },

    .predict_task = function(task) {
      target = task$target_names
      col_roles = task$col_roles
      key_cols = col_roles$key
      order_cols = col_roles$order

      full = task$backend$data(rows = task$backend$rownames, cols = c(target, key_cols, order_cols))
      roll_spec = private$.roll_spec(target)
      if (length(key_cols) > 0L) {
        setorderv(full, c(key_cols, order_cols))
        full[, (roll_spec$cols) := fcst_rolls(get(target), roll_spec), by = key_cols]
      } else {
        setorderv(full, order_cols)
        set(full, j = roll_spec$cols, value = fcst_rolls(full[[target]], roll_spec))
      }

      active = task$data(cols = c(key_cols, order_cols))
      set(full, j = target, value = NULL)
      active_rolls = full[active, on = c(key_cols, order_cols)][, roll_spec$cols, with = FALSE]
      task$select(task$feature_names)$cbind(active_rolls)
    },

    .roll_spec = function(target) {
      pv = self$param_set$get_values(tags = "train")
      grid = CJ(fun = pv$funs, size = pv$window_sizes, sorted = FALSE)
      list(
        fun = grid$fun,
        size = grid$size,
        lag = pv$lag,
        cols = sprintf("%s_roll_%s_%i", target, grid$fun, grid$size)
      )
    }
  )
)

fcst_rolls = function(x, spec) {
  rolls = list(mean = frollmean, median = frollmedian, sd = frollsd, min = frollmin, max = frollmax, sum = frollsum)
  shifted = shift(x, n = spec$lag)
  map(seq_along(spec$fun), function(i) invoke(rolls[[spec$fun[i]]], x = shifted, n = spec$size[i]))
}

#' @include zzz.R
register_po("fcst.rolling", PipeOpFcstRolling)
