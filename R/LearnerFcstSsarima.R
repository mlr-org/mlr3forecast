#' @title State-Space ARIMA Forecast Learner
#'
#' @name mlr_learners_fcst.ssarima
#'
#' @description
#' State-Space ARIMA model. Supports multiple seasonal lags natively
#' (e.g. `lags = c(1, 24, 168)` for hourly data with daily and weekly cycles).
#' Calls [smooth::ssarima()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.ssarima
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstSsarima = R6Class(
  "LearnerFcstSsarima",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        orders = p_uty(default = list(ar = 0, i = 1, ma = 1), tags = "train"),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        constant = p_lgl(default = FALSE, tags = "train"),
        arma = p_uty(default = NULL, tags = "train"),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
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
        id = "fcst.ssarima",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "State-Space ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.ssarima"
      )
    }
  ),

  private = list(
    .fn = "ssarima"
  )
)

#' @include zzz.R
register_learner("fcst.ssarima", LearnerFcstSsarima)
