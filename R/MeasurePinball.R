#' @title Pinball Loss
#'
#' @name mlr_measures_fcst.pinball
#'
#' @description
#' Measures the quality of quantile (probabilistic) forecasts using the pinball loss, also known as the quantile
#' loss. The loss is averaged over all observations and all predicted quantile levels. Smaller scores indicate
#' better calibrated quantile forecasts.
#'
#' @details
#' For a single quantile level \eqn{\tau} with forecast \eqn{q_i} and observation \eqn{y_i} the pinball loss is
#' \deqn{
#'   L_\tau(y_i, q_i) =
#'   \begin{cases}
#'     \tau\,(y_i - q_i), & \text{if } y_i \ge q_i \\
#'     (1 - \tau)\,(q_i - y_i), & \text{if } y_i < q_i
#'   \end{cases}
#' }{
#'   L_tau(y, q) = max(tau * (y - q), (tau - 1) * (y - q))
#' }
#' The reported score is twice the mean of \eqn{L_\tau} over all observations and all quantile levels
#' \eqn{\tau}, matching the convention used by \CRANpkg{fabletools} so that the median (\eqn{\tau = 0.5})
#' pinball loss equals the mean absolute error.
#'
#' @references
#' `r format_bib("koenker1978regression")`
#'
#' @templateVar id fcst.pinball
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasurePinball = R6Class(
  "MeasurePinball",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "fcst.pinball",
        predict_type = "quantiles",
        range = c(0, Inf),
        minimize = TRUE,
        packages = "mlr3forecast",
        label = "Pinball Loss",
        man = "mlr3forecast::mlr_measures_fcst.pinball"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      truth = prediction$truth
      quantiles = prediction$data$quantiles
      probs = attr(quantiles, "probs")

      e = truth - quantiles
      tau = matrix(probs, nrow = nrow(quantiles), ncol = length(probs), byrow = TRUE)
      loss = pmax(tau * e, (tau - 1) * e)
      2 * mean(loss, na.rm = TRUE)
    }
  )
)

#' @include zzz.R
register_measure("fcst.pinball", MeasurePinball)
