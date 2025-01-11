PipeOpTargetTrafoDifference = R6Class("PipeOpTargetTrafoDifference",
  inherit = PipeOpTargetTrafo,
  public = list(
    initialize = function(id = "fcst.targetdiff", param_vals = list()) {
      param_set = ps(
        lag = p_int(1L, tags = c("train", "required"))
      )
      param_set$set_values(lag = 1L)

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        task_type_in = "TaskRegr"
      )
    }
  ),
  private = list(
    .get_state = function(task) {
      pv = self$param_set$get_values(tags = "train")
      list(first = task$data(cols = task$target_names)[[1L]][pv$lag])
    },

    .transform = function(task, phase) {
      pv = self$param_set$get_values(tags = "train")
      x = task$data(cols = task$target_names)[[1L]]
      new_target = diff(x, lag = pv$lag)
      new_target = c(rep(NA_real_, pv$lag), new_target)
      new_target = as.data.table(new_target)
      setnames(new_target, paste0(task$target_names, ".diff"))
      task$cbind(new_target)
      # TODO: check difference to task$rename, difference seems to be in backend logic
      convert_task(task, target = names(new_target), drop_original_target = TRUE)
    },

    .invert = function(prediction, predict_phase_state) {
      response = self$state$first + cumsum(prediction$response)
      PredictionRegr$new(
        row_ids = prediction$row_ids,
        truth = predict_phase_state$truth,
        response = response
      )
    }
  )
)

#' @include zzz.R
register_po("fcst.targetdiff", PipeOpTargetTrafoDifference)
