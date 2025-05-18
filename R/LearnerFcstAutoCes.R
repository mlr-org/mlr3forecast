#' @title Auto CES Forecast Learner
#'
#' @name mlr_learners_fcst.auto_ces
#'
#' @description
#' Auto CES model.
#' Calls [smooth::auto.ces()] from package \CRANpkg{smooth}.
#'
#' @templateVar id fcst.auto_ces
#' @template learner
#'
#' @references
#' `r format_bib()`
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
      param_set = ps()

      super$initialize(
        id = "fcst.auto_ces",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
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

      xreg = NULL
      if (length(task$feature_names) > 0L) {
        xreg = as.matrix(task$data(cols = task$feature_names))
      }
      invoke(smooth::auto.ces, y = as.ts(task), xreg = xreg, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.auto_ces", LearnerFcstAutoCes)
