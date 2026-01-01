#' @title Random Walk Forecast Learner
#'
#' @name mlr_learners_fcst.random_walk
#'
#' @description
#' Random walk model.
#' Calls [forecast::rw_model()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.random_walk
#' @template learner
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstRandomWalk = R6Class(
  "LearnerFcstRandomWalk",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        lag = p_int(1L, default = 1L, tags = "train"),
        drift = p_lgl(default = FALSE, tags = "train"),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = "fcst.random_walk",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Random walk",
        man = "mlr3forecast::mlr_learners_fcst.random_walk"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(forecast::rw_model, y = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.random_walk", LearnerFcstRandomWalk)
