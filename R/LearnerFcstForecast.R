#' @title Abstract class for forecast package learner
#' @keywords internal
LearnerFcstForecast = R6Class(
  "LearnerFcstForecast",
  inherit = LearnerFcst,
  private = list(
    .max_index = NULL,

    .train = function(task) {
      properties = task$properties
      if ("ordered" %nin% properties) {
        stopf("%s learner requires an ordered task.", self$id)
      }
      if ("keys" %chin% properties) {
        stopf("%s learner does not support tasks with keys.", self$id)
      }
      private$.max_index = max(task$data(cols = task$col_roles$order)[[1L]])
    },

    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      is_quantile = self$predict_type == "quantiles"

      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          stopf("Quantile prediction not supported for in-sample prediction.")
        }
        pred = self$model$fitted[task$row_ids]
        return(list(response = pred))
      }

      if ("featureless" %chin% self$properties || length(task$feature_names) == 0L) {
        args = list(h = length(task$row_ids))
      } else {
        newdata = as.matrix(task$data(cols = task$feature_names))
        args = list(xreg = newdata)
      }
      if (is_quantile) {
        args = insert_named(args, list(level = quantiles_to_level(private$.quantiles)))
      }
      pred = invoke(forecast::forecast, self$model, .args = args)

      if (!is_quantile) {
        return(list(response = as.numeric(pred$mean)))
      }

      pred$lower = pred$lower[, rev(seq_len(ncol(pred$lower)))]
      quantiles = cbind(pred$lower, if (0.5 %in% private$.quantiles) pred$mean, pred$upper)
      attr(quantiles, "probs") = private$.quantiles
      attr(quantiles, "response") = private$.quantile_response
      list(quantiles = quantiles)
    },

    .is_newdata = function(task) {
      order_cols = task$col_roles$order
      idx = task$backend$data(rows = task$row_ids, cols = order_cols)[[1L]]
      !any(private$.max_index %in% idx)
    }
  )
)
