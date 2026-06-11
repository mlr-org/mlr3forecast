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
      invoke(fn, private$.smooth_data(task), .args = pv)
    },

    .predict = function(task) {
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))
      if (!private$.is_newdata(task)) {
        response = private$.fitted()[task$row_ids]
        return(insert_named(prediction, list(response = response)))
      }
      args = list(h = task$nrow)
      if ("exogenous" %in% self$properties && task$n_features > 0L) {
        args$newdata = task$data(cols = task$feature_names)
      }
      pred = invoke(generics::forecast, self$model, .args = args)
      insert_named(prediction, list(response = as.numeric(pred$mean)))
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
