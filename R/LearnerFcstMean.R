#' @title Mean Forecast Learner
#'
#' @name mlr_learners_fcst.mean
#'
#' @description
#' Mean model.
#' Calls [forecast::mean_model()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.mean
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018fpp")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstMean = R6Class(
  "LearnerFcstMean",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = "fcst.mean",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Mean",
        man = "mlr3forecast::mlr_learners_fcst.mean"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(forecast::mean_model, y = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.mean", LearnerFcstMean)
