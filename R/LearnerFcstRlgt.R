#' @title Local and Global Trend Forecast Learner
#'
#' @name mlr_learners_fcst.rlgt
#'
#' @description
#' Bayesian exponential smoothing with a nonlinear global trend (LGT/SGT), Student-t errors, and optional
#' heteroscedasticity, fitted via MCMC. The seasonal period is taken from the frequency of the series.
#' Calls [Rlgt::rlgt()] from package \CRANpkg{Rlgt}.
#'
#' @templateVar id fcst.rlgt
#' @template learner
#'
#' @references
#' `r format_bib("smyl2025rlgt")`
#'
#' @export
#' @template seealso_learner
#' @template example_slow
LearnerFcstRlgt = R6Class(
  "LearnerFcstRlgt",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        seasonality = p_int(1L, default = 1L, tags = "train"),
        seasonality2 = p_int(1L, default = 1L, tags = "train"),
        seasonality.type = p_fct(c("multiplicative", "generalized"), default = "multiplicative", tags = "train"),
        error.size.method = p_fct(c("std", "innov"), default = "std", tags = "train"),
        level.method = p_fct(c("HW", "seasAvg", "HW_sAvg"), default = "HW", tags = "train"),
        method = p_fct(c("Gibbs", "Stan"), default = "Gibbs", tags = "train"),
        homoscedastic = p_lgl(default = FALSE, tags = "train"),
        control = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_list(x, null.ok = TRUE))
        ),
        verbose = p_lgl(default = FALSE, tags = "train"),
        NUM_OF_TRIALS = p_int(1L, default = 2000L, tags = "predict")
      )

      super$initialize(
        id = "fcst.rlgt",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous"),
        packages = c("mlr3forecast", "Rlgt"),
        label = "Local and Global Trend",
        man = "mlr3forecast::mlr_learners_fcst.rlgt"
      )
    }
  ),

  private = list(
    .pkg = "Rlgt",
    .fn = "rlgt",

    .fitted = function() {
      error_config("In-sample prediction is not supported for %s.", self$id)
    },

    .postprocess = function(pred) {
      h = length(pred$mean)
      if (!is.null(pred$lower) && nrow(pred$lower) != h) {
        pred$lower = t(pred$lower)
        pred$upper = t(pred$upper)
      }
      pred
    }
  )
)

#' @include zzz.R
register_learner("fcst.rlgt", LearnerFcstRlgt)
