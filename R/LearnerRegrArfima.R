#' @title ARFIMA
#'
#' @name mlr_learners_fcst.arfima
#'
#' @description
#' ARFIMA model.
#' Calls [forecast::arfima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.arfima
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018automatic")`
#'
#' @export
#' @template seealso_learner
LearnerFcstArfima = R6Class("LearnerFcstArfima",
  inherit = LearnerRegrForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps()

      super$initialize(
        id = "fcst.arfima",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "logical", "integer", "numeric"),
        properties = c("univariate", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "ARFIMA",
        man = "mlr3forecast::mlr_learners_fcst.arfima"
      )
    }
  ),

  private = list(
    .train = function(task) {
      if ("ordered" %nin% task$properties) {
        stopf("%s learner requires an ordered task.", self$id)
      }
      private$.max_index = max(task$data(cols = task$col_roles$order)[[1L]])
      pv = self$param_set$get_values(tags = "train")
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }

      if (is_task_featureless(task)) {
        xreg = NULL
      } else {
        xreg = as.matrix(task$data(cols = fcst_feature_names(task)))
      }
      invoke(forecast::arfima,
        y = stats::ts(task$data(cols = task$target_names)[[1L]]),
        xreg = xreg,
        .args = pv
      )
    }
  )
)

#' @include zzz.R
register_learner("fcst.arfima", LearnerFcstArfima)
