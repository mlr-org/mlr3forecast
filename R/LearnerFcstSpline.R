#' @title Spline Forecast Learner
#'
#' @name mlr_learners_fcst.spline
#'
#' @description
#' Cubic spline stochastic model.
#' Calls [forecast::spline_model()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.spline
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2005local")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstSpline = R6Class(
  "LearnerFcstSpline",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        method = p_fct(c("gcv", "mle"), default = "gcv", tags = "train"),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = "fcst.spline",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Spline",
        man = "mlr3forecast::mlr_learners_fcst.spline"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(forecast::spline_model, y = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.spline", LearnerFcstSpline)
