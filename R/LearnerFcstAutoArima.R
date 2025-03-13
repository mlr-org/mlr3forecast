#' @title Auto ARIMA
#'
#' @name mlr_learners_fcst.auto_arima
#'
#' @description
#' Auto ARIMA model.
#' Calls [forecast::auto.arima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.auto_arima
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018automatic", "wang2006characteristic")`
#'
#' @export
#' @template seealso_learner
LearnerFcstAutoArima = R6Class(
  "LearnerFcstAutoArima",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        d = p_int(0L, default = NA, tags = "train", special_vals = list(NA)),
        D = p_int(0L, default = NA, tags = "train", special_vals = list(NA)),
        max.q = p_int(0L, default = 5, tags = "train"),
        max.p = p_int(0L, default = 5, tags = "train"),
        max.P = p_int(0L, default = 2, tags = "train"),
        max.Q = p_int(0L, default = 2, tags = "train"),
        max.order = p_int(0L, default = 5, tags = "train"),
        max.d = p_int(0L, default = 2, tags = "train"),
        max.D = p_int(0L, default = 1, tags = "train"),
        start.p = p_int(0L, default = 2, tags = "train"),
        start.q = p_int(0L, default = 2, tags = "train"),
        start.P = p_int(0L, default = 2, tags = "train"),
        start.Q = p_int(0L, default = 2, tags = "train"),
        stepwise = p_lgl(default = FALSE, tags = "train"),
        allowdrift = p_lgl(default = TRUE, tags = "train"),
        seasonal = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.auto_arima",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "logical", "integer", "numeric"),
        properties = "missings",
        packages = c("mlr3forecast", "forecast"),
        label = "Auto ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.arima"
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

      xreg = NULL
      if (!is_task_featureless(task)) {
        xreg = as.matrix(task$data(cols = fcst_feature_names(task)))
      }
      invoke(forecast::auto.arima, y = as.ts(task), xreg = xreg, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.auto_arima", LearnerFcstAutoArima)
