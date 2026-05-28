#' @title Holt-Winters Forecast Learner
#'
#' @name mlr_learners_fcst.holt_winters
#'
#' @description
#' Holt-Winters exponential smoothing with optional trend and additive or multiplicative seasonal component.
#' Smoothing parameters are estimated by minimizing the squared one-step prediction error.
#' Calls [stats::HoltWinters()] from package \pkg{stats} and forecasts via [forecast::forecast()].
#'
#' Setting `beta = FALSE` fits a simple exponential smoothing model (no trend).
#' Setting `gamma = FALSE` fits a non-seasonal model.
#'
#' @templateVar id fcst.holt_winters
#' @template learner
#'
#' @references
#' `r format_bib("holt2004forecasting", "winters1960forecasting")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstHoltWinters = R6Class(
  "LearnerFcstHoltWinters",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        alpha = p_dbl(0, 1, default = NULL, special_vals = list(NULL), tags = "train"),
        beta = p_dbl(0, 1, default = NULL, special_vals = list(NULL, FALSE), tags = "train"),
        gamma = p_dbl(0, 1, default = NULL, special_vals = list(NULL, FALSE), tags = "train"),
        seasonal = p_fct(c("additive", "multiplicative"), default = "additive", tags = "train"),
        start.periods = p_int(2L, default = 2L, tags = "train"),
        l.start = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        b.start = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        s.start = p_uty(default = NULL, special_vals = list(NULL), tags = "train", custom_check = check_numeric),
        optim.start = p_uty(
          default = c(alpha = 0.3, beta = 0.1, gamma = 0.1),
          tags = "train",
          custom_check = check_numeric
        ),
        optim.control = p_uty(default = list(), tags = "train", custom_check = check_list),
        lambda = p_uty(default = NULL, tags = "predict"),
        biasadj = p_lgl(default = FALSE, tags = "predict")
      )

      super$initialize(
        id = "fcst.holt_winters",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Holt-Winters",
        man = "mlr3forecast::mlr_learners_fcst.holt_winters"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(stats::HoltWinters, x = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.holt_winters", LearnerFcstHoltWinters)
