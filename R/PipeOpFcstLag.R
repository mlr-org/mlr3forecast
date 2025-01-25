#' @title Creat Lags of Target Variable
#' @name mlr_pipeops_fcst.lag
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
PipeOpFcstLag = R6Class("PipeOpFcstLag",
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
        feature_types = c("numeric", "integer", "Date", "factor") # NOTE: this filters based on features
      )
    }
  ),

  private = list(
    .train_task = function(task) {
      pv = self$param_set$get_values(tags = "train")
      lags = pv$lags
      target = task$target_names
      key_cols = task$col_roles$key
      order_cols = task$col_roles$order
      dt = task$data()
      self$state = list(dt = dt[(.N - max(lags)):.N])
      nms = sprintf("%s_lag_%i", target, lags)
      if (length(key_cols) > 0L) {
        setorderv(dt, c(key_cols, order_cols))
        dt[, (nms) := shift(.SD, lags), by = key_cols, .SDcols = target]
      } else {
        setorderv(dt, order_cols)
        dt[, (nms) := shift(.SD, lags), .SDcols = target]
      }
      task$select(task$feature_names)$cbind(dt)
    },

    .predict_task = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      lags = pv$lags
      target = task$target_names
      key_cols = task$col_roles$key
      order_cols = task$col_roles$order
      dt = rbind(self$state$dt, task$data())
      nms = sprintf("%s_lag_%i", target, lags)
      if (length(key_cols) > 0L) {
        setorderv(dt, c(key_cols, order_cols))
        dt[, (nms) := shift(.SD, lags), by = key_cols, .SDcols = target]
      } else {
        setorderv(dt, order_cols)
        dt[, (nms) := shift(.SD, lags), .SDcols = target]
      }
      dt = dt[(.N - task$nrow + 1L):.N]
      task$select(task$feature_names)$cbind(dt)
    },

    .predict_task_original = function(task) {
      cols = self$state$dt_columns
      if (!length(cols)) {
        return(task)
      }
      dt = task$data(cols = cols)
      dt = as.data.table(private$.predict_dt(dt, task$levels(cols)))
      task$select(setdiff(task$feature_names, cols))$cbind(dt)
    },

    .train_task_original = function(task) {
      dt_columns = private$.select_cols(task)
      cols = dt_columns
      if (!length(cols)) {
        self$state = list(dt_columns = dt_columns)
        return(task)
      }
      dt = task$data(cols = cols)

      dt = if (test_r6(task, classes = "TaskSupervised")) {
        as.data.table(private$.train_dt(dt, task$levels(cols), task$truth()))
      } else {
        as.data.table(private$.train_dt(dt, task$levels(cols)))
      }

      self$state$dt_columns = dt_columns
      task$select(setdiff(task$feature_names, cols))$cbind(dt)
    },

    .train_dt = function(dt, levels, target) {
      # this wouldn't allow sorting since we don't get the task here,
      # as well as getting the target name
      pv = self$param_set$get_values()
      lags = pv$lags
      nms = sprintf("target_lag_%i", lags)
      dt[, target := target]
      dt[, (nms) := shift(.SD, lags), .SDcols = "target"]
      dt[, target := NULL]
      dt
    },

    .predict_dt = function(dt, levels) {
      .NotYetImplemented()
    }
  )
)

#' @include zzz.R
register_po("fcst.lags", PipeOpFcstLag)
