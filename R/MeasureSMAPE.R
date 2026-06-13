#' @title Symmetric Mean Absolute Percentage Error
#'
#' @name mlr_measures_fcst.smape
#'
#' @description
#' Measure of the symmetric mean absolute percentage error of forecasts.
#' Unlike the ordinary percentage error, it is bounded between 0 and 200 and treats over- and
#' under-forecasting more symmetrically.
#'
#' @details
#' \deqn{
#'   \mathrm{sMAPE} = \frac{100}{n} \sum_{i=1}^n
#'     \frac{2\,\lvert y_i - \hat y_i \rvert}{\lvert y_i \rvert + \lvert \hat y_i \rvert}
#' }{
#'   100 * mean(2 * |y - yhat| / (|y| + |yhat|))
#' }
#'
#' @references
#' `r format_bib("hyndman2006another")`
#'
#' @templateVar id fcst.smape
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureSMAPE = R6Class(
  "MeasureSMAPE",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.smape",
        range = c(0, 200),
        minimize = TRUE,
        predict_type = "response",
        packages = "mlr3forecast",
        label = "Symmetric Mean Absolute Percentage Error",
        man = "mlr3forecast::mlr_measures_fcst.smape"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      truth = prediction$truth
      response = prediction$response
      mean(2 * abs(truth - response) / (abs(truth) + abs(response)), na.rm = TRUE) * 100
    }
  )
)

#' @include zzz.R
register_measure("fcst.smape", MeasureSMAPE)
