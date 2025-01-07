#' @title ARIMA
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
#' `r format_bib("hyndman2018automatic")`
#'
#' @export
#' @template seealso_learner
LearnerFcstAutoARIMA = R6Class("LearnerFcstAutoARIMA",
  inherit = LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        d          = p_int(0L, default = NA, tags = "train", special_vals = list(NA)),
        D          = p_int(0L, default = NA, tags = "train", special_vals = list(NA)),
        max.q      = p_int(0L, default = 5, tags = "train"),
        max.p      = p_int(0L, default = 5, tags = "train"),
        max.P      = p_int(0L, default = 2, tags = "train"),
        max.Q      = p_int(0L, default = 2, tags = "train"),
        max.order  = p_int(0L, default = 5, tags = "train"),
        max.d      = p_int(0L, default = 2, tags = "train"),
        max.D      = p_int(0L, default = 1, tags = "train"),
        start.p    = p_int(0L, default = 2, tags = "train"),
        start.q    = p_int(0L, default = 2, tags = "train"),
        start.P    = p_int(0L, default = 2, tags = "train"),
        start.Q    = p_int(0L, default = 2, tags = "train"),
        stepwise   = p_lgl(default = FALSE, tags = "train"),
        allowdrift = p_lgl(default = TRUE, tags = "train"),
        seasonal   = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.auto_arima",
        param_set = param_set,
        feature_types = c("Date", "logical", "integer", "numeric"),
        packages = c("mlr3forecast", "forecast"),
        label = "Auto ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.arima"
      )
    }
  ),

  private = list(
    .max_index = NULL,

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
        invoke(forecast::auto.arima,
          y = stats::ts(task$data(cols = task$target_names)[[1L]]),
          .args = pv
        )
      } else {
        xreg = as.matrix(task$data(cols = fcst_feature_names(task)))
        invoke(forecast::auto.arima,
          y = stats::ts(task$data(cols = task$target_names)[[1L]]),
          xreg = xreg,
          .args = pv
        )
      }
    },

    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      if (private$.is_newdata(task)) {
        if (is_task_featureless(task)) {
          prediction = invoke(forecast::forecast, self$model, h = length(task$row_ids))
        } else {
          newdata = as.matrix(task$data(cols = fcst_feature_names(task)))
          prediction = invoke(forecast::forecast, self$model, xreg = newdata)
        }
        list(response = prediction$mean)
      } else {
        prediction = stats::fitted(self$model)[task$row_ids]
        list(response = prediction)
      }
    },

    .is_newdata = function(task) {
      order_cols = task$col_roles$order
      idx = task$backend$data(rows = task$row_ids, cols = order_cols)[[1L]]
      !any(private$.max_index %in% idx)
    }
  )
)

#' @include zzz.R
register_learner("fcst.auto_arima", LearnerFcstAutoARIMA)
