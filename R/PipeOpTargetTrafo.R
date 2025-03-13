PipeOpTargetTrafoDifference = R6Class(
  "PipeOpTargetTrafoDifference",
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
      lag = self$param_set$get_values(tags = "train")$lag
      target = task$data(cols = task$target_names)[[1L]]
      list(
        head = target[lag],
        tail = tail(target, lag)
      )
    },

    .transform = function(task, phase) {
      lag = self$param_set$get_values(tags = "train")$lag
      x = task$data(cols = task$target_names)[[1L]]
      if (phase == "predict") {
        x = c(self$state$tail, x)
      }
      new_target = diff(x, lag = lag)
      new_target = as.data.table(new_target)
      setnames(new_target, paste0(task$target_names, ".diff"))
      # TODO: check if there is a better approach
      if (phase == "train") {
        row_ids = task$row_ids
        row_ids = row_ids[(1L + lag):length(row_ids)]
        task$filter(row_ids)
      }
      task$cbind(new_target)
      # TODO: check difference to task$rename, difference seems to be in backend logic
      convert_task(task, target = names(new_target), drop_original_target = TRUE)
    },

    .invert = function(prediction, predict_phase_state) {
      .NotYetImplemented()
      response = self$state$head + cumsum(prediction$response)
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
