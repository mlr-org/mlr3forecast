#' @title Box-Cox Transform the Target Variable
#' @name mlr_pipeops_fcst.targetboxcox
#'
#' @description
#' Applies a Box-Cox transformation to the target variable to stabilize the variance, producing the new target
#' `BoxCox(y, lambda)`. The transformation is pointwise and monotonic, so no rows are dropped and predictions are
#' inverted via [forecast::InvBoxCox()].
#'
#' `lambda = 0` is the log transformation. When `lambda` is `NULL` (default) it is estimated from the training data
#' via [forecast::BoxCox.lambda()], using the task frequency for the `"guerrero"` method so seasonality is accounted
#' for. The estimated (or supplied) `lambda` is stored and reused at predict time and for inversion.
#'
#' Box-Cox and log transformations require strictly positive target values; non-positive values produce `NaN` or an
#' error from [forecast::BoxCox()].
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTargetTrafo], as well as the following:
#' * `lambda` :: `numeric(1)` | `NULL`\cr
#'   Box-Cox transformation parameter. `NULL` (default) estimates it from the training data, `0` is the log
#'   transformation, any other numeric is used as a fixed value.
#' * `method` :: `character(1)`\cr
#'   Method used to estimate `lambda` when `lambda = NULL`, one of `"guerrero"` (default) or `"loglik"`. See
#'   [forecast::BoxCox.lambda()].
#' * `lower` :: `numeric(1)`\cr
#'   Lower bound for the estimated `lambda`. Default `-1`.
#' * `upper` :: `numeric(1)`\cr
#'   Upper bound for the estimated `lambda`. Default `2`.
#'
#' @section Limitations:
#' This PipeOp must not be placed *inside* a [RecursiveForecaster] or [DirectForecaster] graph. Inside
#' [RecursiveForecaster] the transformation would entangle with the iterative lag/rolling feedback, which reads the
#' original-scale backend, producing a train/predict scale mismatch (rejected at construction). Use inside a plain
#' [mlr3pipelines::GraphLearner] via `ppl("targettrafo", ...)` for batch prediction, or wrap the forecaster itself with
#' `ppl("targettrafo", ...)` so all horizons are inverted together.
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#' flrn = as_learner(ppl("targettrafo",
#'   graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
#'   trafo_pipeop = po("fcst.targetboxcox")
#' ))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
PipeOpTargetTrafoBoxCox = R6Class(
  "PipeOpTargetTrafoBoxCox",
  inherit = PipeOpTargetTrafo,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.targetboxcox"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.targetboxcox", param_vals = list()) {
      param_set = ps(
        lambda = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        method = p_fct(c("guerrero", "loglik"), default = "guerrero", tags = c("train", "estimate")),
        lower = p_dbl(default = -1, tags = c("train", "estimate")),
        upper = p_dbl(default = 2, tags = c("train", "estimate"))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines", "forecast"),
        task_type_in = "TaskRegr"
      )
    }
  ),

  private = list(
    .get_state = function(task) {
      lambda = self$param_set$get_values(tags = "train")$lambda
      if (is.null(lambda)) {
        x = if (inherits(task, "TaskFcst")) as.ts(task) else task$data(cols = task$target_names)[[1L]]
        lambda = invoke(forecast::BoxCox.lambda, x, .args = self$param_set$get_values(tags = "estimate"))
      }
      list(lambda = lambda)
    },

    .transform = function(task, phase) {
      x = task$data(cols = task$target_names)[[1L]]
      new_target = as.data.table(as.numeric(forecast::BoxCox(x, self$state$lambda)))
      setnames(new_target, paste0(task$target_names, ".bc"))
      task$cbind(new_target)
      convert_task(task, target = names(new_target), drop_original_target = TRUE)
    },

    .invert = function(prediction, predict_phase_state) {
      inverted = as.numeric(forecast::InvBoxCox(prediction$response, self$state$lambda))
      PredictionFcst$new(
        row_ids = prediction$row_ids,
        truth = predict_phase_state$truth,
        response = inverted,
        extra = prediction$data$extra
      )
    }
  )
)

#' @include zzz.R
register_po("fcst.targetboxcox", PipeOpTargetTrafoBoxCox)
