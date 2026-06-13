#' @title Exponential Smoothing Forecast Learner
#'
#' @name mlr_learners_fcst.es
#'
#' @description
#' Exponential smoothing (ETS) model in state-space form. Supports multiple seasonal lags natively
#' (e.g. `lags = c(1, 24, 168)` for hourly data with daily and weekly cycles).
#' Calls [smooth::es()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.es
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstEs = R6Class(
  "LearnerFcstEs",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        model = p_uty(default = "ZXZ", tags = "train"),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        persistence = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, null.ok = TRUE))
        ),
        phi = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        initialSeason = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, null.ok = TRUE))
        ),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("usual", "admissible", "none"), default = "usual", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select"), default = "use", tags = "train")
      )

      super$initialize(
        id = "fcst.es",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Exponential Smoothing",
        man = "mlr3forecast::mlr_learners_fcst.es"
      )
    }
  ),

  private = list(
    .fn = "es"
  )
)

#' @include zzz.R
register_learner("fcst.es", LearnerFcstEs)
