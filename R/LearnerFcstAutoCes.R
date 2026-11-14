#' @include LearnerFcstSmooth.R
#' @title Auto CES Forecast Learner
#'
#' @name mlr_learners_fcst.auto_ces
#'
#' @description
#' Complex Exponential Smoothing (CES) with automatic selection of the seasonal component.
#' Supports multiple seasonal lags (e.g. `lags = c(1, 24, 168)` for hourly data with daily and weekly cycles).
#' Calls [smooth::auto.ces()] from package \CRANpkg{smooth}.
#'
#' @template section_custom_period
#'
#' @templateVar id fcst.auto_ces
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstAutoCes = R6Class(
  "LearnerFcstAutoCes",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        seasonality = p_uty(
          default = c("none", "simple", "partial", "full"),
          tags = "train",
          custom_check = crate(function(x) {
            check_subset(x, choices = c("none", "simple", "partial", "full"), empty.ok = FALSE)
          })
        ),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        initial = p_fct(
          c("backcasting", "optimal", "two-stage", "complete", "gradient"),
          default = "backcasting",
          tags = "train"
        ),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        loss = p_fct(c("likelihood", "MSE", "MAE", "HAM"), default = "likelihood", tags = "train"),
        bounds = p_fct(c("admissible", "none"), default = "admissible", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train")
      )

      super$initialize(
        id = "fcst.auto_ces",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous"),
        packages = c("mlr3forecast", "smooth"),
        label = "Auto CES",
        man = "mlr3forecast::mlr_learners_fcst.auto_ces"
      )
    }
  ),

  private = list(
    .fn = "auto.ces"
  )
)

#' @include zzz.R
register_learner("fcst.auto_ces", LearnerFcstAutoCes)
