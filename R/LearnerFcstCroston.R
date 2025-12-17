#' @title Croston Forecast Learner
#'
#' @name mlr_learners_fcst.croston
#'
#' @description
#' Croston model.
#' Calls [forecast::croston_model()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.croston
#' @template learner
#'
#' @references
#' `r format_bib("croston1972forecasting", "shale2006forecasting", "shenstone2005stochastic", "syntetos2001bias")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstCroston = R6Class(
  "LearnerFcstCroston",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        alpha = p_dbl(0, 1, default = 0.1, tags = "train"),
        type = p_fct(c("croston", "sba", "sbj"), default = "croston", tags = "train")
      )

      super$initialize(
        id = "fcst.croston",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Croston",
        man = "mlr3forecast::mlr_learners_fcst.croston"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(forecast::croston_model, y = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.croston", LearnerFcstCroston)
