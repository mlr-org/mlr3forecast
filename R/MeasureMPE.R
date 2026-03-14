#' @title Mean Percentage Error
#'
#' @name mlr_measures_fcst.mpe
#'
#' @description
#' Measure of the average signed percentage error of forecasts.
#' Positive values indicate systematic under-forecasting, negative values indicate over-forecasting.
#'
#' @details
#' \deqn{
#'   \mathrm{MPE} = \frac{100}{n} \sum_{i=1}^n \frac{y_i - \hat y_i}{y_i}
#' }{
#'   100 * mean((y - yhat) / y)
#' }
#'
#' @templateVar id fcst.mpe
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureMPE = R6Class(
  "MeasureMPE",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.mpe",
        range = c(-Inf, Inf),
        minimize = NA,
        predict_type = "response",
        packages = "mlr3forecast",
        label = "Mean Percentage Error",
        man = "mlr3forecast::mlr_measures_fcst.mpe"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      truth = prediction$truth
      response = prediction$response
      mean((truth - response) / truth, na.rm = TRUE) * 100
    }
  )
)

#' @include zzz.R
register_measure("fcst.mpe", MeasureMPE)
