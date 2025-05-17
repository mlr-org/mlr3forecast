#' @title Mean Directional Accuracy
#'
#' @name mlr_measures_fcst.mda
#'
#' @description
#' Measure of the proportion of correctly predicted directions between successive observations in forecast tasks.
#'
#' @details
#' \deqn{
#'   \mathrm{MDA} = (a - b)\,\frac{1}{n-1}
#'     \sum_{i=2}^n \mathbf{1}\{\mathrm{sign}(y_i - y_{i-1})
#'     = \mathrm{sign}(\hat y_i - \hat y_{i-1})\} \;+\; p
#' }{
#'   (a - b)\,\frac{1}{n-1}\sum I(\sign(y_i - y_{i-1}) = \sign(\hat y_i - \hat y_{i-1})) + b
#' }
#' where `a` is the reward for a correct direction (default `1`), `b` is the penalty for an incorrect direction
#' (default `0`), and `n` is the number of observations.
#'
#' @param reward `numeric(1)`\cr
#'   Reward applied when the predicted direction matches the true direction.
#' @param penalty `numeric(1)`\cr
#'   Penalty applied when the predicted direction does not match.
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
      param_set = ps(reward = p_dbl(default = 1), penalty = p_dbl(default = 0))

      super$initialize(
        id = "fcst.mda",
        task_type = "regr",
        param_set = param_set,
        minimize = FALSE,
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
      response = prediction$response

      resid = truth - response
      actual_change = diff(truth)
      actual_direction = sign(actual_direction)
      pred_change = actual_change - resid[-1L]
      pred_direction = sign(pred_change)
      directional_accuracy = actual_direction == pred_direction
      (reward - penalty) * mean(directional_accuracy, na.rm = TRUE) + penalty
    }
  )
)

#' @title Mean Directional Value
#'
#' @name mlr_measures_fcst.mdv
#'
#' @description
#' Measure of average magnitude‐weighted directional accuracy in forecast tasks.
#'
#' @details
#' \deqn{
#'   \mathrm{MDV} = \frac{1}{n-1}
#'     \sum_{i=2}^n \lvert y_i - y_{i-1}\rvert \times
#'     \begin{cases}
#'       +1, & \text{if }\mathrm{sign}(y_i - y_{i-1})
#'            = \mathrm{sign}(\hat y_i - \hat y_{i-1}),\\
#'       -1, & \text{otherwise.}
#'     \end{cases}
#' }{
#'   \text{mean}(\lvert\Delta y\rvert \times \text{directional indicator})
#' }
#' where `n` is the number of observations.
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
        task_type = "regr",
        minimize = FALSE,
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

      resid = truth - response
      actual_change = diff(truth)
      actual_direction = sign(actual_change)
      pred_change = actual_change - resid[-1L]
      pred_direction = sign(pred_change)
      directional_accuracy = fifelse(actual_direction == pred_direction, 1L, -1L)
      mean(abs(actual_change) * directional_accuracy, na.rm = TRUE)
    }
  )
)

#' @title Mean Directional Percentage Value
#'
#' @name mlr_measures_fcst.mdpv
#'
#' @description
#' Measure of average percentage‐weighted directional accuracy in forecast tasks.
#'
#' @details
#' \deqn{
#'   \mathrm{MDPV} = \frac{100}{n-1}
#'     \sum_{i=2}^n \left\lvert\frac{y_i - y_{i-1}}{y_{i-1}}\right\rvert \times
#'     \begin{cases}
#'       +1, & \text{if }\mathrm{sign}(y_i - y_{i-1})
#'            = \mathrm{sign}(\hat y_i - \hat y_{i-1}),\\
#'       -1, & \text{otherwise.}
#'     \end{cases}
#' }{
#'   100 \times \text{mean}\bigl(\lvert\Delta y / y_{-}\rvert \times \text{directional indicator}\bigr)
#' where `n` is the number of observations.
#' }
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
        task_type = "regr",
        minimize = FALSE,
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

      resid = truth - response
      actual_change = diff(truth)
      actual_direction = sign(actual_change)
      pred_change = actual_change - resid[-1L]
      pred_direction = sign(pred_change)
      directional_accuracy = fifelse(actual_direction == pred_direction, 1L, -1L)
      mean(abs(actual_change / truth[-1L]) * directional_accuracy, na.rm = na.rm) * 100
    }
  )
)

#' @include zzz.R
register_measure("fcst.mda", MeasureMDA)
register_measure("fcst.mdv", MeasureMDV)
register_measure("fcst.mdpv", MeasureMDPV)
