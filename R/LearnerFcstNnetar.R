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
LearnerFcstNnetar = R6Class(
  "LearnerFcstNnetar",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        p = p_uty(tags = "train"),
        P = p_int(0L, default = 1L, tags = "train"),
        size = p_int(tags = "train"),
        repeats = p_int(default = 20L, tags = "train"),
        lambda = p_uty(default = NULL, tags = "train"),
        scale.inputs = p_lgl(default = TRUE, tags = "train")
      )

      super$initialize(
        id = "fcst.nnetar",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Neural Network Time Series Forecasts",
        man = "mlr3forecast::mlr_learners_fcst.nnetar"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      xreg = NULL
      if (length(task$feature_names) > 0L) {
        xreg = as.matrix(task$data(cols = task$feature_names))
      }
      invoke(forecast::nnetar, y = as.ts(task), xreg = xreg, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.nnetar", LearnerFcstNnetar)
