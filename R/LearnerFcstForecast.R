#' @title Abstract class for forecast package learner
#' @keywords internal
LearnerFcstForecast = R6Class(
  "LearnerFcstForecast",
  inherit = LearnerFcst,
  private = list(
    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      is_quantile = self$predict_type == "quantiles"

      res = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          stopf("Quantile prediction not supported for in-sample prediction.")
        }
        response = stats::fitted(self$model)[task$row_ids]
        res = insert_named(res, list(response = response))
        return(res)
      }

      if ("exogenous" %chin% self$properties && task$n_features > 0L) {
        newdata = as.matrix(task$data(cols = task$feature_names))
        args = list(xreg = newdata)
      } else {
        args = list(h = task$nrow)
      }
      if (is_quantile) {
        args = insert_named(args, list(level = quantiles_to_level(private$.quantiles)))
      }
      pred = invoke(forecast::forecast, self$model, .args = args)

      if (!is_quantile) {
        res = insert_named(res, list(response = as.numeric(pred$mean)))
        return(res)
      }

      pred$lower = pred$lower[, rev(seq_len(ncol(pred$lower)))]
      quantiles = cbind(pred$lower, if (0.5 %in% private$.quantiles) pred$mean, pred$upper)
      setattr(quantiles, "probs", private$.quantiles)
      setattr(quantiles, "response", private$.quantile_response)
      insert_named(res, list(quantiles = quantiles))
    }
  )
)
