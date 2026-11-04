#' @title Autocorrelation at Lag 1
#'
#' @name mlr_measures_fcst.acf1
#'
#' @description
#' Computes the sample autocorrelation of forecast residuals at lag 1 using [stats::acf()].
#' Values close to zero indicate little linear dependence between consecutive residuals.
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
        properties = "requires_task",
        label = "Autocorrelation at Lag 1",
        man = "mlr3forecast::mlr_measures_fcst.acf1"
      )
    }
  ),

  private = list(
    .score = function(prediction, task, ...) {
      if ("keys" %chin% task$properties) {
        return(score_grouped(private$.score_ungrouped, prediction, task, ...))
      }
      private$.score_ungrouped(prediction, task, ...)
    },

    .score_ungrouped = function(prediction, task, ...) {
      o = chrono_order(prediction, task)
      resid = prediction$truth[o] - prediction$response[o]
      if (length(resid) <= 1L) {
        return(NA_real_)
      }
      stats::acf(resid, plot = FALSE, lag.max = 1L, na.action = stats::na.pass)$acf[2L, 1L, 1L]
    }
  )
)

#' @include zzz.R
register_measure("fcst.acf1", MeasureACF1)
