#' @include LearnerFcstForecast.R
#' @title Neural Network Forecast Learner
#'
#' @name mlr_learners_fcst.nnetar
#'
#' @description
#' Single Layer Neural Network.
#' Calls [forecast::nnetar()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.nnetar
#' @template learner
#'
#' @references
#' `r format_bib("ripley_1996")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstNnetar = R6Class(
  "LearnerFcstNnetar",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        p = p_int(0L, tags = "train"),
        P = p_int(0L, default = 1L, tags = "train"),
        size = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        repeats = p_int(1L, default = 20L, tags = "train"),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        scale.inputs = p_lgl(default = TRUE, tags = "train"),
        parallel = p_lgl(default = FALSE, tags = "train"),
        num.cores = p_int(
          lower = 1L,
          default = 2L,
          special_vals = list(NULL),
          tags = c("train", "threads")
        ),
        # additional arguments to nnet::nnet
        decay = p_dbl(0, default = 0, tags = "train"),
        maxit = p_int(1L, default = 100L, tags = "train"),
        rang = p_dbl(0, default = 0.7, tags = "train"),
        skip = p_lgl(default = FALSE, tags = "train"),
        MaxNWts = p_int(1L, default = 1000L, tags = "train"),
        abstol = p_dbl(0, default = 1e-4, tags = "train"),
        reltol = p_dbl(0, default = 1e-8, tags = "train"),
        bootstrap = p_lgl(default = FALSE, tags = "predict"),
        npaths = p_int(1L, default = 1000L, tags = "predict"),
        innov = p_uty(
          default = NULL,
          tags = "predict",
          custom_check = crate(function(x) check_numeric(x, null.ok = TRUE))
        )
      )

      super$initialize(
        id = "fcst.nnetar",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast", "nnet"),
        label = "Neural Network Time Series Forecasts",
        man = "mlr3forecast::mlr_learners_fcst.nnetar"
      )
    }
  ),

  private = list(
    .fn = "nnetar",
    .parallel_arg = "parallel",

    .adjust_predict_args = function(args, is_quantile) {
      if (is_quantile && any(private$.quantiles != 0.5)) {
        args$PI = TRUE
      }
      args
    }
  )
)

#' @include zzz.R
register_learner("fcst.nnetar", LearnerFcstNnetar)
