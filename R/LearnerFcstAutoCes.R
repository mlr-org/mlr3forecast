#' @title Auto CES Forecast Learner
#'
#' @name mlr_learners_fcst.auto_ces
#'
#' @description
#' Auto Complex Exponential Smoothing (CES) model.
#' Calls [smooth::auto.ces()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.auto_ces
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
LearnerFcstAutoCes = R6Class(
  "LearnerFcstAutoCes",
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
        id = "fcst.auto_ces",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Auto CES",
        man = "mlr3forecast::mlr_learners_fcst.auto_ces"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(smooth::auto.ces, y = as.ts(task), .args = pv)
    },

    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      if (!private$.is_newdata(task)) {
        response = stats::fitted(self$model)[task$row_ids]
        return(list(response = response))
      }
      args = list(h = task$nrow)
      pred = invoke(generics::forecast, self$model, .args = args)
      list(response = as.numeric(pred$mean))
    }
  )
)

#' @include zzz.R
register_learner("fcst.auto_ces", LearnerFcstAutoCes)
