#' @title Abstract class for setartree package learners
#' @keywords internal
#' @include LearnerFcst.R
LearnerFcstSetar = R6Class(
  "LearnerFcstSetar",
  inherit = LearnerFcst,
  private = list(
    .fn = NULL,

    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      y = as.numeric(task$data(cols = task$target_names, ordered = TRUE)[[1L]])
      context = private$.set_context(private$.fit(y, pv), task)
      # forecast() starts from the end of the passed series, so keep the training history
      context$y = y
      context
    },

    .fit = function(y, pv) {
      fn = getExportedValue("setartree", private$.fn)
      invoke(fn, data = list(y), .args = pv)
    },

    .fitted = function() {
      error_config("In-sample prediction is not supported for %s.", self$id)
    },

    .predict = function(task) {
      is_quantile = self$predict_type == "quantiles"
      if (is_quantile) {
        assert_quantiles(self, quantile_response = TRUE)
      }
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        return(insert_named(prediction, list(response = private$.fitted_response(task))))
      }

      args = list(newdata = list(self$model$y), h = task$nrow)
      if (is_quantile) {
        level = quantiles_to_levels(private$.quantiles)
        if (length(level) > 0L) {
          # pass fractions, since setartree rescales levels that are all below 1
          args$level = level / 100
        }
      }
      pred = invoke(generics::forecast, self$native_model, .args = args)$forecast[[1L]]

      if (!is_quantile) {
        return(insert_named(prediction, list(response = as.numeric(pred$mean))))
      }

      insert_named(prediction, list(quantiles = private$.quantiles_from_intervals(pred)))
    }
  )
)
