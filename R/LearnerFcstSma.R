#' @title Simple Moving Average Forecast Learner
#'
#' @name mlr_learners_fcst.sma
#'
#' @description
#' Simple moving average. The forecast is the mean of the last `order` observations.
#' If `order` is `NULL` (the default), the optimal window is selected automatically
#' according to the chosen information criterion `ic`.
#' Calls [smooth::sma()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.sma
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstSma = R6Class(
  "LearnerFcstSma",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        order = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        holdout = p_lgl(default = FALSE, tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        fast = p_lgl(default = TRUE, tags = "train")
      )

      super$initialize(
        id = "fcst.sma",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Simple Moving Average",
        man = "mlr3forecast::mlr_learners_fcst.sma"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      private$.set_context(invoke(smooth::sma, y = as.ts(task), .args = pv), task)
    },

    .predict = function(task) {
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))
      if (!private$.is_newdata(task)) {
        response = private$.fitted_response(task)
        prediction = insert_named(prediction, list(response = response))
        return(prediction)
      }
      pred = invoke(generics::forecast, self$native_model, h = task$nrow)
      insert_named(prediction, list(response = as.numeric(pred$mean)))
    }
  )
)

#' @include zzz.R
register_learner("fcst.sma", LearnerFcstSma)
