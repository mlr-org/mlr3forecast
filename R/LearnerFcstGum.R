#' @title GUM Forecast Learner
#'
#' @name mlr_learners_fcst.gum
#'
#' @description
#' Generalised Univariate Model (GUM): a single-source-of-error state-space model with a user-defined transition matrix,
#' persistence vector and measurement vector. Generalises exponential smoothing beyond the ETS structural template.
#' Calls [smooth::gum()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.gum
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstGum = R6Class(
  "LearnerFcstGum",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        orders = p_uty(default = c(1, 1), tags = "train", custom_check = check_integerish),
        lags = p_uty(tags = "train", custom_check = check_integerish),
        type = p_fct(c("additive", "multiplicative"), default = "additive", tags = "train"),
        initial = p_fct(c("backcasting", "optimal", "two-stage", "complete"), default = "backcasting", tags = "train"),
        persistence = p_uty(default = NULL, special_vals = list(NULL), tags = "train"),
        transition = p_uty(default = NULL, special_vals = list(NULL), tags = "train"),
        measurement = p_uty(default = NULL, special_vals = list(NULL), tags = "train"),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "MSEh", "TMSE", "GTMSE", "MSCE", "GPL"),
          default = "likelihood",
          tags = "train"
        ),
        holdout = p_lgl(default = FALSE, tags = "train"),
        bounds = p_fct(c("usual", "admissible", "none"), default = "usual", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt", "integrate"), default = "use", tags = "train")
      )

      super$initialize(
        id = "fcst.gum",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "Generalised Univariate Model",
        man = "mlr3forecast::mlr_learners_fcst.gum"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(smooth::gum, y = as.ts(task), .args = pv)
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
register_learner("fcst.gum", LearnerFcstGum)
