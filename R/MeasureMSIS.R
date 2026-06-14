#' @title Mean Scaled Interval Score
#'
#' @name mlr_measures_fcst.msis
#'
#' @description
#' Measures the quality of central prediction intervals, scaling the interval (Winkler) score by the
#' in-sample mean absolute error of the naive (or seasonal naive) forecast. The interval score rewards
#' narrow intervals and penalizes observations falling outside them, and the scaling makes the measure
#' comparable across series of different magnitudes. This is the prediction-interval metric used in the
#' M4 competition. Smaller scores indicate better calibrated and narrower intervals.
#'
#' @details
#' For a central interval at level `1 - alpha` with lower and upper bounds \eqn{l_i} and \eqn{u_i}
#' (the `alpha/2` and `1 - alpha/2` quantiles):
#' \deqn{
#'   \mathrm{MSIS} = \frac{\frac{1}{n} \sum_{i=1}^n (u_i - l_i)
#'     + \frac{2}{\alpha}(l_i - y_i)\mathbf{1}\{y_i < l_i\}
#'     + \frac{2}{\alpha}(y_i - u_i)\mathbf{1}\{y_i > u_i\}}
#'     {\frac{1}{T-m} \sum_{t=m+1}^T \lvert z_t - z_{t-m} \rvert}
#' }{
#'   MSIS = mean((u - l) + (2/alpha) * (max(l - y, 0) + max(y - u, 0))) / mean(|diff(z, lag = m)|)
#' }
#' where \eqn{z} is the training series, \eqn{m} is the seasonal period, and \eqn{T} is the length of
#' the training series. For keyed tasks the score is computed per series and averaged.
#'
#' @references
#' `r format_bib("gneiting2007scoring", "makridakis2020m4")`
#'
#' @templateVar id fcst.msis
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureMSIS = R6Class(
  "MeasureMSIS",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        alpha = p_dbl(lower = 0, upper = 1, tags = "required"),
        period = p_int(lower = 1L, tags = "required")
      )
      param_set$set_values(alpha = 0.05, period = 1L)

      super$initialize(
        id = "fcst.msis",
        param_set = param_set,
        predict_type = "quantiles",
        range = c(0, Inf),
        minimize = TRUE,
        packages = "mlr3forecast",
        properties = c("requires_task", "requires_train_set"),
        label = "Mean Scaled Interval Score",
        man = "mlr3forecast::mlr_measures_fcst.msis"
      )
    }
  ),
  private = list(
    .score = function(prediction, task, train_set, ...) {
      probs = attr(prediction$data$quantiles, "probs")
      if ("keys" %in% task$properties) {
        return(score_grouped(private$.score_ungrouped, prediction, task, train_set, probs = probs, ...))
      }
      private$.score_ungrouped(prediction, task, train_set, probs = probs, ...)
    },

    .score_ungrouped = function(prediction, task, train_set, probs, ...) {
      pv = self$param_set$get_values()
      alpha = pv$alpha
      lower_prob = alpha / 2
      upper_prob = 1 - alpha / 2
      assert_choice(lower_prob, probs)
      assert_choice(upper_prob, probs)

      truth = prediction$truth
      quantiles = prediction$data$quantiles
      lt = quantiles[, which(probs == lower_prob)]
      ut = quantiles[, which(probs == upper_prob)]
      interval_score = (ut - lt) + (2 / alpha) * (pmax(lt - truth, 0) + pmax(truth - ut, 0))

      train = task$data(rows = train_set, cols = task$target_names)[[1L]]
      scale = mean(abs(diff(train, lag = pv$period)), na.rm = TRUE)
      mean(interval_score, na.rm = TRUE) / scale
    }
  )
)

#' @include zzz.R
register_measure("fcst.msis", MeasureMSIS)
