#' @title ARIMA
#'
#' @name mlr_learners_fcst.arima
#'
#' @description
#' ...
#'
#' @templateVar id fcst.arima
#' @template learner
#'
#' @references
#' ...
#'
#' @export
#' @template seealso_learner
LearnerFcstARIMA = R6Class("LearnerFcstARIMA",
  inherit = LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {

      ps = ps(
        order = p_uty(default = c(0, 0, 0), tags = "train"),
        seasonal = p_uty(default = c(0, 0, 0), tags = "train"),
        include.mean = p_lgl(default = TRUE, tags = "train"),
        include.drift = p_lgl(default = FALSE, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train"),
        method = p_fct(c("CSS-ML", "ML", "CSS"), default = "CSS-ML", tags = "train")
      )

      super$initialize(
        id = "fcst.arima",
        param_set = ps,
        feature_types = c("logical", "integer", "numeric"),
        packages = c("mlr3learners", "forecast"),
        label = "ARIMA",
        man = "mlr3learners::mlr_learners_arima.arima"
      )
    }
  ),

  private = list(
    .max_index = NULL,

    .train = function(task) {
      if (length(task$col_roles$order) == 0L) {
        stopf("%s learner requires an ordered task.", self$id)
      }
      private$.max_index = max(task$data(cols = task$col_roles$order)[[1L]])
      pv = self$param_set$get_values(tags = "train")
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }
      if (length(task$feature_names) > 0) {
        xreg = as.matrix(task$data(cols = task$feature_names))
        invoke(forecast::Arima,
          y = task$data(rows = task$row_ids, cols = task$target_names),
          xreg = xreg,
          .args = pv
        )
      } else {
        invoke(forecast::Arima,
          y = task$data(rows = task$row_ids, cols = task$target_names),
          .args = pv)
      }
    },

    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      if (private$.is_newdata(task)) {
        if (length(task$feature_names) > 0) {
          newdata = as.matrix(task$data(cols = task$feature_names))
          prediction = invoke(forecast::forecast, self$model, xreg = newdata)
        } else {
          prediction = invoke(forecast::forecast, self$model, h = length(task$row_ids))
          browser()
        }
        list(response = prediction$mean)
      } else {
        prediction = stats::fitted(self$model[task$row_ids])
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
