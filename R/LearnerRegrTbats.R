#' @title TBATS
#'
#' @name mlr_learners_fcst.tbats
#'
#' @description
#' TBATS model.
#' Calls [forecast::tbats()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.tbats
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018automatic")`
#'
#' @export
#' @template seealso_learner
LearnerFcstTbats = R6Class("LearnerFcstTbats",
  inherit = LearnerRegrForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        use.box.cox = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        use.trend = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        use.damped.trend = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        seasonal.periods = p_uty(default = NULL, tags = "train"),
        use.arma.errors = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        use.parallel = p_uty(tags = "train"),
        num.cores = p_int(1L, default = 2L, special_vals = list(NULL), tags = "train"),
        bc.lower = p_int(default = 0, tags = "train"),
        bc.upper = p_int(default = 1, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.tbats",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "integer", "numeric"),
        properties = c("univariate", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "TBATS",
        man = "mlr3forecast::mlr_learners_fcst.tbats"
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

      invoke(forecast::tbats,
        y = stats::ts(task$data(cols = task$target_names)[[1L]]),
        .args = pv
      )
    }
  )
)

#' @include zzz.R
register_learner("fcst.tbats", LearnerFcstTbats)
