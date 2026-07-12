#' @title Multilayer Perceptron Forecast Learner
#'
#' @name mlr_learners_fcst.mlp
#'
#' @description
#' Automatic time series forecasting with a multilayer perceptron neural network, including automatic input lag
#' selection, deterministic seasonality handling, and ensemble combination across multiple training repetitions.
#' Calls [nnfor::mlp()] from package \CRANpkg{nnfor}.
#'
#' @templateVar id fcst.mlp
#' @template learner
#'
#' @references
#' `r format_bib("kourentzes2014neural")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstMlp = R6Class(
  "LearnerFcstMlp",
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
        allow.det.season = p_lgl(default = TRUE, tags = "train"),
        det.type = p_fct(c("auto", "bin", "trg"), default = "auto", tags = "train"),
        hd.auto.type = p_fct(c("set", "valid", "cv", "elm"), default = "set", tags = "train"),
        hd.max = p_int(1L, special_vals = list(NULL), default = NULL, tags = "train"),
        retrain = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.mlp",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = "featureless",
        packages = c("mlr3forecast", "nnfor", "forecast"),
        label = "Multilayer Perceptron",
        man = "mlr3forecast::mlr_learners_fcst.mlp"
      )
    }
  ),

  private = list(
    .pkg = "nnfor",
    .fn = "mlp",

    .fitted = function() {
      model = self$native_model
      fitted = as.numeric(stats::fitted(model))
      c(rep.int(NA_real_, length(model$y) - length(fitted)), fitted)
    }
  )
)

#' @include zzz.R
register_learner("fcst.mlp", LearnerFcstMlp)
