#' @title Auto GUM Forecast Learner
#'
#' @name mlr_learners_fcst.auto_gum
#'
#' @description
#' Automatic selection over Generalised Univariate Model (GUM) specifications via an information criterion.
#' Calls [smooth::auto.gum()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.auto_gum
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstAutoGum = R6Class(
  "LearnerFcstAutoGum",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        orders = p_int(1L, default = 3L, tags = "train"),
        lags = p_int(1L, tags = "train"),
        type = p_fct(c("additive", "multiplicative", "select"), default = "additive", tags = "train"),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("usual", "admissible", "none"), default = "usual", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt", "integrate"), default = "use", tags = "train")
      )

      super$initialize(
        id = "fcst.auto_gum",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Auto GUM",
        man = "mlr3forecast::mlr_learners_fcst.auto_gum"
      )
    }
  ),

  private = list(
    .fn = "auto.gum"
  )
)

#' @include zzz.R
register_learner("fcst.auto_gum", LearnerFcstAutoGum)
