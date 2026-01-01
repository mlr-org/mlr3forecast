#' @title Theta Forecast Learner
#'
#' @name mlr_learners_fcst.theta
#'
#' @description
#' Theta model.
#' Calls [forecast::theta_model()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.theta
#' @template learner
#'
#' @references
#' `r format_bib("assimakopoulos2000theta", "hyndman2003unmasking")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstTheta = R6Class(
  "LearnerFcstTheta",
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
        id = "fcst.theta",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Theta",
        man = "mlr3forecast::mlr_learners_fcst.theta"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(forecast::theta_model, y = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.theta", LearnerFcstTheta)
