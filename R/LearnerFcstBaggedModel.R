#' @title Bagged Model Forecast Learner
#'
#' @name mlr_learners_fcst.bagged
#'
#' @description
#' Bootstrap-aggregated forecasts. The series is resampled via the Box-Cox/Loess moving block bootstrap of Bergmeir,
#' Hyndman, and Benítez and `fn` is fit on each replicate. The forecast averages across the ensemble.
#' Calls [forecast::baggedModel()] from package \CRANpkg{forecast}.
#'
#' `fn` is the model-fitting function applied to each bootstrap replicate (defaults to [forecast::ets()]). Any function
#' returning an object compatible with [forecast::forecast()] may be passed, e.g. [forecast::auto.arima()] or
#' [forecast::Arima()] with fixed orders via a wrapper. The number of bootstrap replicates is controlled by `num`, and
#' `block_size` configures the moving block length in [forecast::bld.mbb.bootstrap()]. Prediction intervals from
#' [forecast::forecast.baggedModel()] are the empirical bootstrap range (not configurable by `level`), so only
#' `"response"` is offered as a `predict_type`.
#'
#' @templateVar id fcst.bagged
#' @template learner
#'
#' @references
#' `r format_bib("bergmeir2016bagging")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstBaggedModel = R6Class(
  "LearnerFcstBaggedModel",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        fn = p_uty(tags = c("train", "bagged"), custom_check = check_function),
        num = p_int(1L, default = 100L, tags = c("train", "mbb")),
        block_size = p_int(1L, default = NULL, special_vals = list(NULL), tags = c("train", "mbb"))
      )

      super$initialize(
        id = "fcst.bagged",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Bagged Model",
        man = "mlr3forecast::mlr_learners_fcst.bagged"
      )
    }
  ),

  private = list(
    .fit = function(task, pv) {
      ps = self$param_set
      y = as.ts(task)
      pv_mbb = ps$get_values(tags = c("train", "mbb"))
      pv_mbb$num = pv_mbb$num %??% 100L
      bootstrapped_series = invoke(forecast::bld.mbb.bootstrap, x = y, .args = pv_mbb)
      invoke(
        forecast::baggedModel,
        y = y,
        bootstrapped_series = bootstrapped_series,
        .args = ps$get_values(tags = c("train", "bagged"))
      )
    }
  )
)

#' @include zzz.R
register_learner("fcst.bagged", LearnerFcstBaggedModel)
