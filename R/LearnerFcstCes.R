#' @title CES Forecast Learner
#'
#' @name mlr_learners_fcst.ces
#'
#' @description
#' CES model.
#' Calls [smooth::ces()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.ces
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth")`
#'
#' @export
#' @template seealso_learner
LearnerFcstCes = R6Class(
  "LearnerFcstCes",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        seasonality = p_fct(c("none", "simple", "partial", "full"), default = "none", tags = "train"),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train"),
        initial = p_fct(c("backcasting", "optimal", "complete"), default = "backcasting", tags = "train"),
        a = p_uty(default = NULL, tags = "train"),
        b = p_uty(default = NULL, tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("admissible", "none"), default = "admissible", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train")
      )

      super$initialize(
        id = "fcst.ces",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "CES",
        man = "mlr3forecast::mlr_learners_fcst.ces"
      )
    }
  ),

  private = list(
    .train = function(task) {
      pv = self$param_set$get_values(tags = "train")
      invoke(smooth::ces, data = as.ts(task), .args = pv)
    },

    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      args = list(h = length(task$row_ids))
      pred = invoke(generics::forecast, self$model, .args = args)
      list(response = as.numeric(pred$mean))
    }
  )
)

#' @include zzz.R
register_learner("fcst.ces", LearnerFcstCes)
