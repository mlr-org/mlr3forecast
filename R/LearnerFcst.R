#' @title Forecast Learner
#'
#' @template param_id
#' @template param_param_set
#' @template param_predict_types
#' @template param_feature_types
#' @template param_learner_properties
#' @template param_data_formats
#' @template param_packages
#' @template param_label
#' @template param_man
#'
#' @template seealso_learner
#' @export
#' @examples
#' # get all regression learners from mlr_learners:
#' lrns = mlr_learners$mget(mlr_learners$keys("^regr"))
#' names(lrns)
#'
#' # get a specific learner from mlr_learners:
#' mlr_learners$get("regr.rpart")
#' lrn("classif.featureless")
LearnerFcst = R6Class("LearnerFcst",
  inherit = LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(id,
                          param_set = ps(),
                          predict_types = "response",
                          feature_types = character(),
                          properties = character(),
                          data_formats,
                          packages = character(),
                          label = NA_character_,
                          man = NA_character_) {
      super$initialize(
        id = id,
        task_type = "fcst",
        param_set = param_set,
        feature_types = feature_types,
        predict_types = predict_types,
        properties = properties,
        data_formats,
        packages = packages,
        label = label,
        man = man
      )
    }
  )
)
