#' @title Mean Directional Accuracy
MeasureMDA = R6Class("MeasureMDA",
  inherit = Measure,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.mdv",
        param_set = ps(),
        task_type = NA_character_,
        properties = character(),
        predict_sets = NULL,
        predict_type = NA_character_,
        range = c(0, Inf),
        minimize = TRUE,
        label = "Mean Directional Accuracy",
        man = "mlr3forecast::mlr_measures_mda"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      .NotYetImplemented()
    }
  )
)

#' @title Mean Directional Value
MeasureMDV = R6Class("MeasureMDV",
  inherit = Measure,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.mdv",
        param_set = ps(),
        task_type = NA_character_,
        properties = character(),
        predict_sets = NULL,
        predict_type = NA_character_,
        range = c(0, Inf),
        minimize = TRUE,
        label = "Mean Directional Value",
        man = "mlr3forecast::mlr_measures_mdv"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      .NotYetImplemented()
    }
  )
)

#' @title Mean Directional Percentage Value
MeasureMDPV = R6Class("MeasureMDPV",
  inherit = Measure,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.mdpv",
        param_set = ps(),
        task_type = NA_character_,
        properties = character(),
        predict_sets = NULL,
        predict_type = NA_character_,
        range = c(0, Inf),
        minimize = TRUE,
        label = "Mean Directional Percentage Value",
        man = "mlr3forecast::mlr_measures_mdpv"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      .NotYetImplemented()
    }
  )
)

#' @include zzz.R
register_measure("fcst.mda", MeasureMDA)
register_measure("fcst.mdv", MeasureMDV)
register_measure("fcst.mdpv", MeasureMDPV)
