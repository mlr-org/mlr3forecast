#' @title Forecast Learner
#'
#' @description
#' This Learner specializes [mlr3::LearnerRegr] for forecast problems:
#'
#' * `task_type` is set to `"fcst"`.
#' * Creates [Prediction]s of class [mlr3::PredictionRegr].
#' * Possible values for `predict_types` are:
#'   - `"response"`: Predicts a numeric response for each observation in the test set.
#'   - `"se"`: Predicts the standard error for each value of response for each observation in the test set.
#'   - `"distr"`: Probability distribution as `VectorDistribution` object (requires package `distr6`, available via
#'     repository \url{https://raphaels1.r-universe.dev}).
#'
#' Predefined learners can be found in the [dictionary][mlr3misc::Dictionary] [mlr3::mlr_learners].
#'
#' @template param_id
#' @template param_param_set
#' @template param_predict_types
#' @template param_feature_types
#' @template param_learner_properties
#' @template param_packages
#' @template param_label
#' @template param_man
#'
#' @template seealso_learner
#' @export
#' @examples
#' # get all forecast learners from mlr_learners:
#' lrns = mlr_learners$mget(mlr_learners$keys("^forecast"))
#' names(lrns)
#'
#' # get a specific learner from mlr_learners:
#' mlr_learners$get("fcst.ets")
#' lrn("fcst.auto_arima")
LearnerFcst = R6Class(
  "LearnerFcst",
  inherit = LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      id,
      param_set = ps(),
      predict_types = "response",
      feature_types = character(),
      properties = character(),
      packages = character(),
      label = NA_character_,
      man = NA_character_
    ) {
      super$initialize(
        id = id,
        task_type = "fcst",
        param_set = param_set,
        feature_types = feature_types,
        predict_types = predict_types,
        properties = properties,
        packages = packages,
        label = label,
        man = man
      )
    }
  )
)
