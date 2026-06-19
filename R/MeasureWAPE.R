#' @title Weighted Absolute Percentage Error
#'
#' @name mlr_measures_fcst.wape
#'
#' @description
#' Measure of the total absolute error of forecasts as a percentage of the total absolute truth.
#' It weights each error by the magnitude of the series, making it robust to individual observations close to
#' zero where the ordinary percentage error is undefined.
#'
#' @details
#' \deqn{
#'   \mathrm{WAPE} = 100 \cdot \frac{\sum_{i=1}^n \lvert y_i - \hat y_i \rvert}{\sum_{i=1}^n \lvert y_i \rvert}
#' }{
#'   100 * sum(|y - yhat|) / sum(|y|)
#' }
#'
#' @templateVar id fcst.wape
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureWAPE = R6Class(
  "MeasureWAPE",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.wape",
        range = c(0, Inf),
        minimize = TRUE,
        predict_type = "response",
        packages = "mlr3forecast",
        label = "Weighted Absolute Percentage Error",
        man = "mlr3forecast::mlr_measures_fcst.wape"
      )
    }
  ),

  private = list(
    .score = function(prediction, ...) {
      truth = prediction$truth
      response = prediction$response
      sum(abs(truth - response), na.rm = TRUE) / sum(abs(truth), na.rm = TRUE) * 100
    }
  )
)

#' @include zzz.R
register_measure("fcst.wape", MeasureWAPE)
