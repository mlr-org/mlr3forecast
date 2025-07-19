#' @title Abstract class for forecast package learner
#' @keywords internal
LearnerFcstForecast = R6Class(
  "LearnerFcstForecast",
  inherit = LearnerFcst,
  private = list(
    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      is_quantile = self$predict_type == "quantiles"

      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          stopf("Quantile prediction not supported for in-sample prediction.")
        }
        response = stats::fitted(self$model)[task$row_ids]
        return(list(response = response))
      }

      if ("exogenous" %chin% self$properties && length(task$feature_names) > 0L) {
        newdata = as.matrix(task$data(cols = task$feature_names))
        args = list(xreg = newdata)
      } else {
        args = list(h = length(task$row_ids))
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
      setattr(quantiles, "probs", private$.quantiles)
      setattr(quantiles, "response", private$.quantile_response)
      list(quantiles = quantiles)
    }
  )
)
