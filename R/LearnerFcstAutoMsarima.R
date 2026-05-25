#' @title Auto Multiple-Seasonal ARIMA Forecast Learner
#'
#' @name mlr_learners_fcst.auto_msarima
#'
#' @description
#' Automatic order selection for Multiple-Seasonal ARIMA. Picks `orders` minimising the chosen
#' information criterion.
#' Calls [smooth::auto.msarima()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.auto_msarima
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstAutoMsarima = R6Class(
  "LearnerFcstAutoMsarima",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        orders = p_uty(default = list(ar = c(3, 3), i = c(2, 1), ma = c(3, 3)), tags = "train"),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("usual", "admissible", "none"), default = "usual", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train")
      )

      super$initialize(
        id = "fcst.auto_msarima",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Auto Multiple-Seasonal ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.auto_msarima"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(smooth::auto.msarima, y = as.ts(task), .args = pv)
    },

    .predict = function(task) {
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))
      if (!private$.is_newdata(task)) {
        response = stats::fitted(self$model)[task$row_ids]
        prediction = insert_named(prediction, list(response = response))
        return(prediction)
      }
      pred = invoke(generics::forecast, self$model, h = task$nrow)
      insert_named(prediction, list(response = as.numeric(pred$mean)))
    }
  )
)

#' @include zzz.R
register_learner("fcst.auto_msarima", LearnerFcstAutoMsarima)
