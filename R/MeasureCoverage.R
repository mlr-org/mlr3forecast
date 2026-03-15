#' @title Empirical Coverage
#'
#' @name mlr_measures_fcst.coverage
#'
#' @description
#' Measures the proportion of true values that fall within the prediction interval.
#' A well-calibrated prediction interval at level \eqn{1 - \alpha} should have coverage close to
#' \eqn{1 - \alpha}.
#'
#' @details
#' \deqn{
#'   \mathrm{Coverage} = \frac{1}{n} \sum_{i=1}^n \mathbf{1}\{l_i \le y_i \le u_i\}
#' }{
#'   mean(l <= y & y <= u)
#' }
#' where \eqn{l_i} and \eqn{u_i} are the lower and upper bounds of the prediction interval and
#' \eqn{y_i} is the observed value.
#'
#' @templateVar id fcst.coverage
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureCoverage = R6Class(
  "MeasureCoverage",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(alpha = p_dbl(lower = 0, upper = 1, tags = "required"))
      param_set$set_values(alpha = 0.05)

      super$initialize(
        id = "fcst.coverage",
        param_set = param_set,
        predict_type = "quantiles",
        range = c(0, 1),
        minimize = FALSE,
        packages = "mlr3forecast",
        label = "Empirical Coverage",
        man = "mlr3forecast::mlr_measures_fcst.coverage"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      alpha = self$param_set$get_values()$alpha
      lower_prob = alpha / 2
      upper_prob = 1 - alpha / 2

      probs = attr(prediction$data$quantiles, "probs")
      assert_choice(lower_prob, probs)
      assert_choice(upper_prob, probs)

      truth = prediction$truth
      lt = prediction$data$quantiles[, which(probs == lower_prob)]
      ut = prediction$data$quantiles[, which(probs == upper_prob)]

      mean(truth >= lt & truth <= ut, na.rm = TRUE)
    }
  )
)

#' @include zzz.R
register_measure("fcst.coverage", MeasureCoverage)
