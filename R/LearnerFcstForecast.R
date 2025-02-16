#' @title Abstract class for forecast package learner
#'
LearnerFcstForecast = R6Class("LearnerFcstForecast",
  inherit = LearnerFcst,
  private = list(
    .max_index = NULL,

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

      if ("featureless" %chin% self$properties || is_task_featureless(task)) {
        args = list(h = length(task$row_ids))
      } else {
        newdata = as.matrix(task$data(cols = fcst_feature_names(task)))
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
      quantiles = cbind(
        pred$lower,
        if (0.5 %in% private$.quantiles) pred$mean,
        pred$upper
      )
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
