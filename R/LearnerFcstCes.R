#' @title CES Forecast Learner
#'
#' @name mlr_learners_fcst.ces
#'
#' @description
#' Complex Exponential Smoothing (CES) model.
#' Calls [smooth::ces()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.ces
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
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
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        a = p_uty(default = NULL, tags = "train"),
        b = p_uty(default = NULL, tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("admissible", "none"), default = "admissible", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train")
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
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(smooth::ces, y = as.ts(task), .args = pv)
    },

    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))
      if (!private$.is_newdata(task)) {
        response = stats::fitted(self$model)[task$row_ids]
        prediction = insert_named(prediction, list(response = response))
        return(prediction)
      }
      args = list(h = task$nrow)
      pred = invoke(generics::forecast, self$model, .args = args)
      insert_named(prediction, list(response = as.numeric(pred$mean)))
    }
  )
)

#' @include zzz.R
register_learner("fcst.ces", LearnerFcstCes)
