#' @title Creat Lags of Target Variable
#' @name mlr_pipeops_fcst.lags
#'
#' @description
#' ...
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreproc],
#' as well as the following parameters:
#' * `lags` :: `integer()`\cr
#'   The lags to create.
#'
#' @export
#' @examples
#' set.seed(1234L)
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
        lags = p_uty(tags = c("train", "predict"), custom_check = check_integerish)
      )
      param_set$set_values(lags = 1L)

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        feature_types = c("numeric", "integer", "Date", "factor"), # NOTE: this filters based on features
        tags = "fcst"
      )
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

      dt = task$data(cols = c(target, key_cols, order_cols))
      self$state = list(history = copy(dt))
      lag_cols = sprintf("%s_lag_%i", target, lags)
      if (length(key_cols) > 0L) {
        setorderv(dt, c(key_cols, order_cols))
        dt[, (lag_cols) := shift(get(target), lags), by = key_cols]
      } else {
        setorderv(dt, order_cols)
        dt[, (lag_cols) := shift(get(target), lags)]
      }
      task$select(task$feature_names)$cbind(dt)
    },

    .predict_task = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      lags = pv$lags
      target = task$target_names
      col_roles = task$col_roles
      key_cols = col_roles$key
      order_cols = col_roles$order

      newdata = task$data(cols = c(target, key_cols, order_cols))
      newdata[, "row_id" := .I]
      history = self$state$history[!newdata, on = c(key_cols, order_cols)]
      combined = rbindlist(list(history, newdata), use.names = TRUE, fill = TRUE)

      lag_cols = sprintf("%s_lag_%i", target, lags)
      if (length(key_cols) > 0L) {
        setorderv(combined, c(key_cols, order_cols))
        combined[, (lag_cols) := shift(get(target), lags), by = key_cols]
      } else {
        setorderv(combined, order_cols)
        combined[, (lag_cols) := shift(get(target), lags)]
      }
      combined = na.omit(combined, cols = "row_id")
      set(combined, j = "row_id", value = NULL)
      task$select(task$feature_names)$cbind(combined)
    }
  )
)

#' @include zzz.R
register_po("fcst.lags", PipeOpFcstLags)
