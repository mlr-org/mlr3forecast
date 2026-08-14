#' @title Sparse ARMA Forecast Learner
#'
#' @name mlr_learners_fcst.sparma
#'
#' @description
#' Sparse ARMA model in state-space form. Unlike ARIMA, which expands polynomials, the AR and MA orders map to
#' specific lags, so `orders = list(ar = c(1, 12), ma = 0)` fits terms at lags 1 and 12 and nothing in between.
#' Calls [smooth::sparma()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.sparma
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstSparma = R6Class(
  "LearnerFcstSparma",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        orders = p_uty(default = list(ar = 1, ma = 1), tags = "train", custom_check = check_list),
        constant = p_lgl(default = FALSE, tags = "train"),
        arma = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_list(x, null.ok = TRUE))
        ),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "LASSO", "RIDGE", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("none", "usual", "admissible"), default = "none", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train")
      )

      super$initialize(
        id = "fcst.sparma",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Sparse ARMA",
        man = "mlr3forecast::mlr_learners_fcst.sparma"
      )
    }
  ),

  private = list(
    .fn = "sparma"
  )
)

#' @include zzz.R
register_learner("fcst.sparma", LearnerFcstSparma)
