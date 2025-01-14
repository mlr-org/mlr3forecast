#' @title Abstract class for forecast package learner
#'
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
