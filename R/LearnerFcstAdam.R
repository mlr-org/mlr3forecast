#' @title ADAM Forecast Learner
#'
#' @name mlr_learners_fcst.adam
#'
#' @description
#' Augmented Dynamic Adaptive Model (ADAM) Forecast Learner model.
#' Calls [smooth::adam()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.adam
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstAdam = R6Class(
  "LearnerFcstAdam",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        model = p_uty(default = "ZXZ", tags = "train"),
        lags = p_uty(tags = "train"),
        orders = p_uty(default = list(ar = 0, i = 0, ma = 0, select = FALSE), tags = "train"),
        constant = p_lgl(default = FALSE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train"),
        occurrence = p_fct(
          c("none", "auto", "fixed", "general", "odds-ratio", "inverse-odds-ratio", "direct"),
          default = "none",
          tags = "train"
        ),
        distribution = p_fct(
          c("default", "dnorm", "dlaplace", "ds", "dgnorm", "dlnorm", "dinvgauss", "dgamma"),
          default = "default",
          tags = "train"
        ),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "LASSO", "RIDGE", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        outliers = p_fct(c("ignore", "use", "select"), default = "ignore", tags = "train"),
        holdout = p_lgl(default = FALSE, tags = "train"),
        persistence = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, null.ok = TRUE))
        ),
        phi = p_uty(default = NULL, tags = "train", custom_check = crate(function(x) check_numeric(x, null.ok = TRUE))),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        arma = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, null.ok = TRUE))
        ),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        bounds = p_fct(c("usual", "admissible", "none"), default = "usual", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        ets = p_fct(c("conventional", "adam"), default = "conventional", tags = "train")
      )

      super$initialize(
        id = "fcst.adam",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "ADAM",
        man = "mlr3forecast::mlr_learners_fcst.adam"
      )
    }
  ),

  private = list(
    .fn = "adam"
  )
)

#' @include zzz.R
register_learner("fcst.adam", LearnerFcstAdam)
