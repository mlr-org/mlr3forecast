#' @title Auto CES Forecast Learner
#'
#' @name mlr_learners_fcst.auto_ces
#'
#' @description
#' Auto Complex Exponential Smoothing (CES) model.
#' Calls [smooth::auto.ces()] from package \CRANpkg{smooth}.
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
        seasonality = p_fct(c("none", "simple", "partial", "full"), default = "none", tags = "train"),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("admissible", "none"), default = "admissible", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train")
      )

      super$initialize(
        id = "fcst.auto_ces",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
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
