#' @title Structural Time Series Forecast Learner
#'
#' @name mlr_learners_fcst.struct_ts
#'
#' @description
#' Structural time series model fit by maximum likelihood. Three model types are supported: local level, local linear
#' trend, and basic structural model (level + trend + seasonal).
#' Calls [stats::StructTS()] from package \pkg{stats}.
#'
#' `type = "BSM"` requires a seasonal time series (frequency > 1). Prediction is performed via
#' [forecast::forecast.StructTS()] which yields point forecasts and predictive intervals from the Kalman filter.
#'
#' @templateVar id fcst.struct_ts
#' @template learner
#'
#' @references
#' `r format_bib("harvey1989forecasting")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstStructTS = R6Class(
  "LearnerFcstStructTS",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        type = p_fct(c("level", "trend", "BSM"), default = "level", tags = "train"),
        init = p_uty(default = NULL, special_vals = list(NULL), tags = "train", custom_check = check_numeric),
        fixed = p_uty(default = NULL, special_vals = list(NULL), tags = "train", custom_check = check_numeric),
        optim.control = p_uty(default = NULL, special_vals = list(NULL), tags = "train", custom_check = check_list),
        lambda = p_uty(default = NULL, tags = "predict"),
        biasadj = p_lgl(default = FALSE, tags = "predict")
      )

      super$initialize(
        id = "fcst.struct_ts",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Structural Time Series",
        man = "mlr3forecast::mlr_learners_fcst.struct_ts"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(stats::StructTS, x = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.struct_ts", LearnerFcstStructTS)
