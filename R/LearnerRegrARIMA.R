#' @title ARIMA
#'
#' @name mlr_learners_fcst.arima
#'
#' @description
#' ARIMA model.
#' Calls [forecast::Arima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.arima
#' @template learner
#'
#' @export
#' @template seealso_learner
LearnerFcstARIMA = R6Class("LearnerFcstARIMA",
  inherit = LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        order = p_uty(
          default = c(0L, 0L, 0L),
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 0L, len = 3L))
        ),
        seasonal = p_uty(
          default = c(0L, 0L, 0L),
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 0L, len = 3L))
        ),
        include.mean = p_lgl(default = TRUE, tags = "train"),
        include.drift = p_lgl(default = FALSE, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train"),
        method = p_fct(c("CSS-ML", "ML", "CSS"), default = "CSS-ML", tags = "train")
      )

      super$initialize(
        id = "fcst.arima",
        param_set = param_set,
        feature_types = c("logical", "integer", "numeric"),
        packages = c("mlr3forecast", "forecast"),
        label = "ARIMA",
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
        invoke(forecast::Arima,
          y = stats::ts(task$data(cols = task$target_names)[[1L]]),
          .args = pv
        )
      } else {
        xreg = as.matrix(task$data(cols = task$feature_names))
        invoke(forecast::Arima,
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
          newdata = as.matrix(task$data(cols = task$feature_names))
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
register_learner("fcst.arima", LearnerFcstARIMA)
