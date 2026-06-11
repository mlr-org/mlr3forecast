#' @title Abstract class for forecast package learner
#' @keywords internal
LearnerFcstForecast = R6Class(
  "LearnerFcstForecast",
  inherit = LearnerFcst,
  private = list(
    .newdata_arg = "xreg",
    .newdata_as_matrix = TRUE,
    .pkg = "forecast",
    .fn = NULL,
    .y_arg = "y",

    .postprocess = function(pred) pred,

    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      private$.fit(task, pv)
    },

    .has_exogenous = function(task) {
      "exogenous" %in% self$properties && task$n_features > 0L
    },

    .fit = function(task, pv) {
      args = set_names(list(as.ts(task)), private$.y_arg)
      if (private$.has_exogenous(task)) {
        args$xreg = as.matrix(task$data(cols = task$feature_names))
      }
      fn = getExportedValue(private$.pkg, private$.fn)
      invoke(fn, .args = insert_named(args, pv))
    },

    .predict = function(task) {
      pv = self$param_set$get_values(tags = "predict")
      is_quantile = self$predict_type == "quantiles"

      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          error_config("Quantile prediction not supported for in-sample prediction.")
        }
        response = private$.fitted()[task$row_ids]
        prediction = insert_named(prediction, list(response = response))
        return(prediction)
      }

      args = list(h = task$nrow)
      if (private$.has_exogenous(task)) {
        newdata = task$data(cols = task$feature_names)
        if (private$.newdata_as_matrix) {
          newdata = as.matrix(newdata)
        }
        args[[private$.newdata_arg]] = newdata
      }
      if (is_quantile) {
        level = quantiles_to_level(private$.quantiles)
        if (length(level) > 0L) {
          args = insert_named(args, list(level = level))
        }
      }
      args = insert_named(args, pv)
      pred = private$.postprocess(invoke(generics::forecast, self$model, .args = args))

      if (!is_quantile) {
        prediction = insert_named(prediction, list(response = as.numeric(pred$mean)))
        return(prediction)
      }

      # quantile p is one side of the symmetric interval with level 100 * |1 - 2p|
      probs = private$.quantiles
      quantiles = map_bc(probs, function(p) {
        if (p == 0.5) {
          as.numeric(pred$mean)
        } else {
          bounds = if (p < 0.5) pred$lower else pred$upper
          as.numeric(bounds[, match(quantiles_to_level(p), level)])
        }
      })
      setattr(quantiles, "probs", probs)
      setattr(quantiles, "response", private$.quantile_response)
      insert_named(prediction, list(quantiles = quantiles))
    }
  )
)
