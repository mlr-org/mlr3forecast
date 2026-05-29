#' @title STL + ETS/ARIMA Forecast Learner
#'
#' @name mlr_learners_fcst.stlm
#'
#' @description
#' Forecasts of seasonal time series using STL decomposition. The seasonal component is forecast naively and the
#' seasonally-adjusted series is forecast with either an `ETS` or `ARIMA` model.
#' Calls [forecast::stlm()] from package \CRANpkg{forecast}.
#'
#' The task must provide a seasonal time series (frequency > 1).
#'
#' @templateVar id fcst.stlm
#' @template learner
#'
#' @references
#' `r format_bib("cleveland1990stl", "hyndman2018fpp")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstStlm = R6Class(
  "LearnerFcstStlm",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        s.window = p_uty(default = 7L + 4L * seq_len(6L), tags = "train"),
        t.window = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        robust = p_lgl(default = FALSE, tags = "train"),
        method = p_fct(c("ets", "arima"), default = "ets", tags = "train"),
        etsmodel = p_uty(default = "ZZN", tags = "train", custom_check = check_string),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict")),
        allow.multiplicative.trend = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = "fcst.stlm",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "STL + ETS/ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.stlm"
      )
    }
  ),

  private = list(
    .newdata_arg = "newxreg",
    .fn = "stlm",

    .fit = function(task, pv) {
      method = pv$method %??% "ets"
      if (task$n_features > 0L && method != "arima") {
        error_input(
          "`fcst.stlm` supports exogenous features only with `method = \"arima\"` (current method: \"%s\").",
          method
        )
      }
      super$.fit(task, pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.stlm", LearnerFcstStlm)
