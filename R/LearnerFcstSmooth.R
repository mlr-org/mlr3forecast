#' @title Abstract class for smooth package learner
#' @keywords internal
#' @include LearnerFcst.R
LearnerFcstSmooth = R6Class(
  "LearnerFcstSmooth",
  inherit = LearnerFcst,
  private = list(
    .fn = NULL,

    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      fn = getExportedValue("smooth", private$.fn)
      private$.set_context(invoke(fn, private$.smooth_data(task), .args = pv), task)
    },

    .predict = function(task) {
      is_quantile = self$predict_type == "quantiles"
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))
      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          error_config("Quantile prediction not supported for in-sample prediction.")
        }
        response = private$.fitted_response(task)
        return(insert_named(prediction, list(response = response)))
      }
      args = list(h = task$nrow)
      if ("exogenous" %in% self$properties && task$n_features > 0L) {
        args$newdata = task$data(cols = task$feature_names)
      }
      if (is_quantile) {
        # smooth takes central-interval levels as fractions, ascending
        level = quantiles_to_levels(private$.quantiles) / 100
        if (length(level) > 0L) {
          args = insert_named(args, list(interval = "prediction", level = level))
        }
      }
      pred = invoke(generics::forecast, self$native_model, .args = args)
      if (!is_quantile) {
        return(insert_named(prediction, list(response = as.numeric(pred$mean))))
      }
      insert_named(prediction, list(quantiles = private$.quantiles_from_intervals(pred)))
    },

    .smooth_data = function(task) {
      y = as.ts(task)
      if ("exogenous" %nin% self$properties || task$n_features == 0L) {
        return(y)
      }
      mat = cbind(as.numeric(y))
      colnames(mat) = task$target_names
      mat = cbind(mat, as.matrix(task$data(cols = task$feature_names)))
      stats::ts(mat, start = stats::start(y), frequency = stats::frequency(y))
    }
  )
)
