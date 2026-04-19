#' @title Difference the Target Variable
#' @name mlr_pipeops_fcst.targetdiff
#'
#' @description
#' Differences the target variable with lag `lag`, producing the new target `y'_t = y_t - y_{t - lag}`. The first `lag`
#' rows are dropped during training. Predictions are inverted via stride-`lag` cumulative sums anchored at the last
#' `lag` training values, yielding original-scale predictions.
#'
#' Use `lag = 1` to remove a trend and `lag = 12` (or the seasonal period) to remove seasonality.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTargetTrafo], as well as the following:
#' * `lag` :: `integer(1)`\cr
#'   Lag to difference at. Default `1L`.
#'
#' @section Limitations:
#' Target transformations are currently **not supported** in combination with [RecursiveForecaster] due to a scale
#' mismatch between the inverted prediction and the transformed lag history. Use inside a plain
#' [mlr3pipelines::GraphLearner] via `ppl("targettrafo", ...)` for batch prediction, or inside [DirectForecaster]
#' where each horizon is predicted in a single batch.
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' graph = ppl("targettrafo",
#'   graph = lrn("regr.rpart"),
#'   trafo_pipeop = po("fcst.targetdiff", lag = 1L)
#' )
#' flrn = DirectForecaster$new(graph, lags = 1:3, horizons = 12L)
#' split = partition(task, ratio = 0.8)
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
PipeOpTargetTrafoDifference = R6Class(
  "PipeOpTargetTrafoDifference",
  inherit = PipeOpTargetTrafo,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.targetdiff"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
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
      list(tail = tail(target, lag))
    },

    .transform = function(task, phase) {
      lag = self$param_set$get_values(tags = "train")$lag
      x = task$data(cols = task$target_names)[[1L]]
      if (phase == "predict") {
        x = c(self$state$tail, x)
      }
      new_target = as.data.table(diff(x, lag = lag))
      setnames(new_target, paste0(task$target_names, ".diff"))
      if (phase == "train") {
        task$filter(tail(task$row_ids, -lag))
      }
      task$cbind(new_target)
      convert_task(task, target = names(new_target), drop_original_target = TRUE)
    },

    .invert = function(prediction, predict_phase_state) {
      lag = self$param_set$get_values(tags = "train")$lag
      inverted = stats::diffinv(prediction$response, lag = lag, xi = self$state$tail)
      inverted = inverted[-seq_len(lag)]
      PredictionRegr$new(row_ids = prediction$row_ids, truth = predict_phase_state$truth, response = inverted)
    }
  )
)

#' @include zzz.R
register_po("fcst.targetdiff", PipeOpTargetTrafoDifference)
