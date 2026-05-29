#' @title Auto State-Space ARIMA Forecast Learner
#'
#' @name mlr_learners_fcst.auto_ssarima
#'
#' @description
#' Automatic order selection for State-Space ARIMA. Picks `orders` minimising the chosen
#' information criterion.
#' Calls [smooth::auto.ssarima()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.auto_ssarima
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstAutoSsarima = R6Class(
  "LearnerFcstAutoSsarima",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        orders = p_uty(default = list(ar = c(3, 3), i = c(2, 1), ma = c(3, 3)), tags = "train"),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        fast = p_lgl(default = TRUE, tags = "train"),
        constant = p_lgl(special_vals = list(NULL), default = NULL, tags = "train"),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("admissible", "usual", "none"), default = "admissible", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train")
      )

      super$initialize(
        id = "fcst.auto_ssarima",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Auto State-Space ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.auto_ssarima"
      )
    }
  ),

  private = list(
    .fn = "auto.ssarima"
  )
)

#' @include zzz.R
register_learner("fcst.auto_ssarima", LearnerFcstAutoSsarima)
