#' @title Mean Directional Accuracy
MeasureMDA = R6Class("MeasureMDA",
  inherit = Measure,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        reward = p_dbl(),
        penalty = p_dbl()
      )
      param_set$set_values(
        reward = 1,
        penalty = 0
      )

      super$initialize(
        id = "fcst.mda",
        param_set = param_set,
        task_type = NA_character_,
        properties = character(),
        predict_sets = c("train", "test"),
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
        predict_sets = c("train", "test"),
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
        predict_sets = c("train", "test"),
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
