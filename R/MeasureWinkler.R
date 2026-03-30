#' @title Winkler Score
#'
#' @name mlr_measures_fcst.winkler
#'
#' @description
#' Measures the quality of prediction intervals by combining their width with a penalty for observations
#' falling outside the interval. Smaller scores indicate better calibrated and narrower intervals.
#'
#' @details
#' \deqn{
#'   W_i =
#'   \begin{cases}
#'     (u_i - l_i) + \frac{2}{\alpha}(l_i - y_i), & \text{if } y_i < l_i \\
#'     (u_i - l_i), & \text{if } l_i \le y_i \le u_i \\
#'     (u_i - l_i) + \frac{2}{\alpha}(y_i - u_i), & \text{if } y_i > u_i
#'   \end{cases}
#' }{
#'   W_i = (u_i - l_i) + (2/alpha) * max(l_i - y_i, 0) + (2/alpha) * max(y_i - u_i, 0)
#' }
#' where \eqn{l_i} and \eqn{u_i} are the lower and upper bounds of the prediction interval,
#' \eqn{y_i} is the observed value, and \eqn{\alpha = 1 - \text{level}/100} is the significance level.
#' The Winkler score is then the mean of \eqn{W_i} over all observations.
#'
#' @references
#' `r format_bib("winkler1972scoring")`
#'
#' @templateVar id fcst.winkler
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureWinkler = R6Class(
  "MeasureWinkler",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(alpha = p_dbl(lower = 0, upper = 1, tags = "required"))
      param_set$set_values(alpha = 0.05)

      super$initialize(
        id = "fcst.winkler",
        param_set = param_set,
        predict_type = "quantiles",
        range = c(0, Inf),
        minimize = TRUE,
        packages = "mlr3forecast",
        label = "Winkler Score",
        man = "mlr3forecast::mlr_measures_fcst.winkler"
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

      width = ut - lt
      # fmt: skip
      score = fcase(
        truth < lt, width + (2 / alpha) * (lt - truth),
        truth > ut, width + (2 / alpha) * (truth - ut),
        default = width
      )
      mean(score, na.rm = TRUE)
    }
  )
)

#' @include zzz.R
register_measure("fcst.winkler", MeasureWinkler)
