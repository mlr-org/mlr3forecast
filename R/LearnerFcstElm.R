#' @title Extreme Learning Machine Forecast Learner
#'
#' @name mlr_learners_fcst.elm
#'
#' @description
#' Automatic time series forecasting with an extreme learning machine neural network, including automatic input lag
#' selection, deterministic seasonality handling, and ensemble combination across multiple training repetitions.
#' Calls [nnfor::elm()] from package \CRANpkg{nnfor}.
#'
#' @templateVar id fcst.elm
#' @template learner
#'
#' @references
#' `r format_bib("kourentzes2014neural")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstElm = R6Class(
  "LearnerFcstElm",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        m = p_int(1L, special_vals = list(NULL), tags = "train"),
        hd = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 1L, null.ok = TRUE))
        ),
        type = p_fct(c("lasso", "ridge", "step", "lm"), default = "lasso", tags = "train"),
        reps = p_int(1L, default = 20L, tags = "train"),
        comb = p_fct(c("median", "mean", "mode"), default = "median", tags = "train"),
        lags = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 1L, null.ok = TRUE))
        ),
        keep = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_logical(x, null.ok = TRUE))
        ),
        difforder = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 0L, null.ok = TRUE))
        ),
        sel.lag = p_lgl(default = TRUE, tags = "train"),
        direct = p_lgl(default = FALSE, tags = "train"),
        allow.det.season = p_lgl(default = TRUE, tags = "train"),
        det.type = p_fct(c("auto", "bin", "trg"), default = "auto", tags = "train"),
        barebone = p_lgl(default = FALSE, tags = "train"),
        retrain = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.elm",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = "featureless",
        packages = c("mlr3forecast", "nnfor", "forecast"),
        label = "Extreme Learning Machine",
        man = "mlr3forecast::mlr_learners_fcst.elm"
      )
    }
  ),

  private = list(
    .pkg = "nnfor",
    .fn = "elm",

    .fitted = function() {
      model = self$native_model
      fitted = as.numeric(stats::fitted(model))
      c(rep(NA_real_, length(model$y) - length(fitted)), fitted)
    }
  )
)

#' @include zzz.R
register_learner("fcst.elm", LearnerFcstElm)
