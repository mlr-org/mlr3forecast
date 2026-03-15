#' @title Autocorrelation at Lag 1
#'
#' @name mlr_measures_fcst.acf1
#'
#' @description
#' Measures the autocorrelation of the forecast residuals at lag 1.
#' Values close to zero indicate that residuals are uncorrelated, while values far from zero suggest
#' the model is not capturing all available information.
#'
#' @details
#' Computed as the sample autocorrelation of the residuals at lag 1 using [stats::acf()].
#'
#' @templateVar id fcst.acf1
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureACF1 = R6Class(
  "MeasureACF1",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.acf1",
        range = c(-1, 1),
        minimize = NA,
        predict_type = "response",
        packages = "mlr3forecast",
        label = "Autocorrelation at Lag 1",
        man = "mlr3forecast::mlr_measures_fcst.acf1"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      warning_input("%s does not support grouped tasks yet, results may be incorrect.", self$id)
      resid = prediction$truth - prediction$response
      if (length(resid) <= 1L) {
        return(NA_real_)
      }
      stats::acf(resid, plot = FALSE, lag.max = 1L, na.action = stats::na.pass)$acf[2L, 1L, 1L]
    }
  )
)

#' @include zzz.R
register_measure("fcst.acf1", MeasureACF1)
