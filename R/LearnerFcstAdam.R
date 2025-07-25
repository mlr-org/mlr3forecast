#' @title ADAM Forecast Learner
#'
#' @name mlr_learners_fcst.adam
#'
#' @description
#' Augmented Dynamic Adaptive Model (ADAM) Forecast Learner model.
#' Calls [smooth::adam()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.adam
#' @template learner
#'
#' @references
#' `r format_bib("svetunkov2023smooth", "svetunkov2023adam")`
#'
#' @export
#' @template seealso_learner
LearnerFcstAdam = R6Class(
  "LearnerFcstAdam",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        model = p_uty(default = "ZXZ", tags = "train"),
        lags = p_uty(tags = "train"),
        orders = p_uty(tags = "train"),
        constant = p_lgl(default = FALSE, tags = "train"),
        regressors = p_fct(c("use", "select", "adapt"), default = "use", tags = "train"),
        occurrence = p_fct(
          c("none", "auto", "fixed", "general", "odds-ratio", "inverse-odds-ratio", "direct"),
          default = "none",
          tags = "train"
        ),
        distribution = p_fct(
          c("default", "dnorm", "dlaplace", "ds", "dgnorm", "dlnorm", "dinvgauss", "dgamma"),
          default = "default",
          tags = "train"
        ),
        loss = p_fct(
          c("likelihood", "MSE", "MAE", "HAM", "LASSO", "RIDGE", "MSEh", "TMSE", "GTMSE", "MSCE"),
          default = "likelihood",
          tags = "train"
        ),
        outliers = p_fct(c("ignore", "use", "select"), default = "ignore", tags = "train"),
        holdout = p_lgl(default = FALSE, tags = "train"),
        persistence = p_uty(default = NULL, tags = "train"),
        phi = p_uty(default = NULL, tags = "train"),
        initial = p_fct(c("optimal", "backcasting", "complete"), default = "optimal", tags = "train"),
        arma = p_uty(default = NULL, tags = "train"),
        ic = p_fct(c("AICc", "AIC", "BIC", "BICc"), default = "AICc", tags = "train"),
        bounds = p_fct(c("usual", "admissible", "none"), default = "usual", tags = "train"),
        silent = p_lgl(default = TRUE, tags = "train")
      )

      super$initialize(
        id = "fcst.adam",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "smooth"),
        label = "ADAM",
        man = "mlr3forecast::mlr_learners_fcst.adam"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      invoke(smooth::adam, data = as.ts(task), .args = pv)
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
register_learner("fcst.adam", LearnerFcstAdam)
