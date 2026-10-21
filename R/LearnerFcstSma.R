#' @include LearnerFcstSmooth.R
#' @title Simple Moving Average Forecast Learner
#'
#' @name mlr_learners_fcst.sma
#'
#' @description
#' Simple moving average. The forecast is the mean of the last `order` observations.
#' If `order` is `NULL` (the default), the optimal window is selected automatically
#' according to the chosen information criterion `ic`.
#' Calls [smooth::sma()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.sma
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstSma = R6Class(
  "LearnerFcstSma",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        order = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        fast = p_lgl(default = TRUE, tags = "train")
      )

      super$initialize(
        id = "fcst.sma",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Simple Moving Average",
        man = "mlr3forecast::mlr_learners_fcst.sma"
      )
    }
  ),

  private = list(
    .fn = "sma",
    # unlike es() and adam(), sma() forecasts 10 steps during fitting by default
    .train_args = list(h = 0L)
  )
)

#' @include zzz.R
register_learner("fcst.sma", LearnerFcstSma)
