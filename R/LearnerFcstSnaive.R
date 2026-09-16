#' @title Seasonal Naive Forecast Learner
#'
#' @name mlr_learners_fcst.snaive
#'
#' @description
#' Seasonal naive model.
#' Each forecast equals the last observed value from the same season, with the seasonal period taken from the task
#' frequency. For non-seasonal tasks this reduces to the naive (random walk) forecast.
#' Calls [forecast::rw_model()] from package \CRANpkg{forecast} with `lag` set to the seasonal period.
#'
#' Use [mlr_learners_fcst.random_walk] to choose the lag manually or to add drift.
#'
#' @templateVar id fcst.snaive
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018fpp")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstSnaive = R6Class(
  "LearnerFcstSnaive",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict")),
        simulate = p_lgl(default = FALSE, tags = "predict"),
        bootstrap = p_lgl(default = FALSE, tags = "predict"),
        npaths = p_int(1L, default = 5000L, tags = "predict")
      )

      super$initialize(
        id = "fcst.snaive",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Seasonal Naive",
        man = "mlr3forecast::mlr_learners_fcst.snaive"
      )
    }
  ),

  private = list(
    .fn = "rw_model",

    .fit = function(task, pv) {
      y = as.ts(task)
      model = invoke(forecast::rw_model, y = y, lag = stats::frequency(y), drift = FALSE, .args = pv)
      private$.tidy_model(model, task)
    }
  )
)

#' @include zzz.R
register_learner("fcst.snaive", LearnerFcstSnaive)
