#' @title Mean Directional Accuracy
#'
#' @name mlr_measures_fcst.mda
#'
#' @references
#' `r format_bib("blaskowitz2011directional")`
#'
#' @templateVar id fcst.mda
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureMDA = R6Class(
  "MeasureMDA",
  inherit = Measure,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(reward = p_dbl(), penalty = p_dbl())
      param_set$set_values(reward = 1, penalty = 0)

      super$initialize(
        id = "fcst.mda",
        task_type = NA_character_,
        param_set = param_set,
        properties = character(),
        predict_type = NA_character_,
        range = c(0, 1),
        minimize = TRUE,
        packages = "mlr3forecast",
        label = "Mean Directional Accuracy",
        man = "mlr3forecast::mlr_measures_fcst.mda"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      pars = self$param_set$get_values()
      penalty = pars$penalty
      reward = pars$reward
      truth = prediction$truth
      actual = prediction$response

      actual_change = diff(truth)
      actual_direction = sign(actual_change)
      predicted_change = actual_change - actual[-1L]
      predicted_direction = sign(predicted_change)
      directional_error = actual_direction == predicted_direction
      (reward - penalty) * mean(directional_error, na.rm = TRUE) + penalty
    }
  )
)

#' @title Mean Directional Value
#'
#' @name mlr_measures_fcst.mdv
#'
#' @references
#' `r format_bib("blaskowitz2011directional")`
#'
#' @templateVar id fcst.mdv
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureMDV = R6Class(
  "MeasureMDV",
  inherit = Measure,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.mdv",
        task_type = NA_character_,
        param_set = ps(),
        properties = character(),
        predict_type = NA_character_,
        minimize = TRUE,
        packages = "mlr3forecast",
        label = "Mean Directional Value",
        man = "mlr3forecast::mlr_measures_fcst.mdv"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      truth = prediction$truth
      response = prediction$response

      actual_change = diff(truth)
      actual_direction = sign(actual_change)
      predicted_change = actual_change - response[-1L]
      predicted_direction = sign(predicted_change)
      directional_accuracy = fifelse(actual_direction == predicted_direction, 1L, -1L)
      mean(abs(actual_change) * directional_accuracy, na.rm = TRUE)
    }
  )
)

#' @title Mean Directional Percentage Value
#'
#' @name mlr_measures_fcst.mdpv
#'
#' @references
#' `r format_bib("blaskowitz2011directional")`
#'
#' @templateVar id fcst.mdpv
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureMDPV = R6Class(
  "MeasureMDPV",
  inherit = Measure,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.mdpv",
        task_type = NA_character_,
        param_set = ps(),
        properties = character(),
        predict_type = NA_character_,
        minimize = TRUE,
        packages = "mlr3forecast",
        label = "Mean Directional Percentage Value",
        man = "mlr3forecast::mlr_measures_fcst.mdpv"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      truth = prediction$truth
      response = prediction$response

      actual_change = diff(truth)
      actual_direction = sign(actual_change)
      predicted_change = actual_change - response[-1L]
      predicted_direction = sign(predicted_change)
      directional_accuracy = fifelse(actual_direction == predicted_direction, 1L, -1L)
      mean(abs(actual_change / truth[-1L]) * directional_accuracy, na.rm = TRUE) * 100
    }
  )
)

#' @include zzz.R
register_measure("fcst.mda", MeasureMDA)
register_measure("fcst.mdv", MeasureMDV)
register_measure("fcst.mdpv", MeasureMDPV)
