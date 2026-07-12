#' @title Time Series Linear Model Forecast Learner
#'
#' @name mlr_learners_fcst.tslm
#'
#' @description
#' Time series linear model.
#' Calls [forecast::tslm()] from package \CRANpkg{forecast}.
#'
#' If `formula` is not set, the model is fit with the `trend` and `season` terms of [forecast::tslm()] plus all
#' features, i.e. `<target> ~ trend + season + <features>`.
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
    .newdata_arg = "newdata",
    .newdata_as_matrix = FALSE,

    .fit = function(task, pv) {
      if (is.null(pv$formula)) {
        pv$formula = task$formula(rhs = c("trend", "season", task$feature_names))
      }
      y = as.ts(task)
      if (task$n_features > 0L) {
        mat = cbind(matrix(y, ncol = 1L), as.matrix(task$data(cols = task$feature_names, ordered = TRUE)))
        colnames(mat)[1L] = task$target_names
      } else {
        mat = matrix(y, ncol = 1L, dimnames = list(NULL, task$target_names))
      }
      data = stats::ts(mat, start = stats::start(y), frequency = stats::frequency(y))
      invoke(forecast::tslm, data = data, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.tslm", LearnerFcstTslm)
