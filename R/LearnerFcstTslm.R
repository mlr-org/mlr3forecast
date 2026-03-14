#' @title Time Series Linear Model Forecast Learner
#'
#' @name mlr_learners_fcst.tslm
#'
#' @description
#' Time series linear model.
#' Calls [forecast::tslm()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.tslm
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018fpp")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstTslm = R6Class(
  "LearnerFcstTslm",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        formula = p_uty(tags = "train", custom_check = check_formula),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = "fcst.tslm",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Time Series Linear Model",
        man = "mlr3forecast::mlr_learners_fcst.tslm"
      )
    }
  ),

  private = list(
    .exogenous_arg = "newdata",

    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      if (is.null(pv$formula)) {
        rhs = c("trend", "season")
        if (task$n_features > 0L) {
          rhs = c(rhs, task$feature_names)
        }
        pv$formula = formulate("y", rhs)
      }
      y = as.ts(task)
      invoke(forecast::tslm, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.tslm", LearnerFcstTslm)
