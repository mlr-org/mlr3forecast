#' @title Abstract class for forecTheta package learners
#' @keywords internal
#' @include LearnerFcst.R
LearnerFcstForecTheta = R6Class(
  "LearnerFcstForecTheta",
  inherit = LearnerFcst,
  private = list(
    .fn = NULL,

    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      y = as.ts(task)
      args = list(y = y, h = 1L, level = NULL)

      xreg = NULL
      if ("exogenous" %chin% self$properties && task$n_features > 0L) {
        xreg = as_numeric_matrix(task$data(cols = task$feature_names, ordered = TRUE))
        args$xreg = rbind(xreg, rep(0, ncol(xreg)))
      }

      fn = getExportedValue("forecTheta", private$.fn)
      model = invoke(fn, .args = insert_named(args, pv))
      context = private$.set_context(model, task)
      insert_named(context, list(xreg = xreg, params = pv))
    },

    .predict = function(task) {
      is_quantile = self$predict_type == "quantiles"
      if (is_quantile) {
        assert_quantiles(self, quantile_response = TRUE)
      }
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          error_config("Quantile prediction not supported for in-sample prediction.")
        }
        return(insert_named(prediction, list(response = private$.fitted_response(task))))
      }

      model = self$native_model
      pv = self$model$params
      pv = insert_named(pv, list(par_ini = as.numeric(model$par), estimation = FALSE))
      if (!is.null(model$lambda)) {
        pv$lambda = model$lambda
      }

      args = list(y = model$y, h = task$nrow, level = NULL)
      if ("exogenous" %chin% self$properties && !is.null(self$model$xreg)) {
        args$xreg = rbind(self$model$xreg, as_numeric_matrix(ordered_features(task, self)))
        n_regressors = length(pv$par_ini) - 3L
        if (is.null(pv$lower)) {
          pv$lower = c(-1e10, 0.1, 1, rep(-1e100, n_regressors))
        } else if (length(pv$lower) == 3L) {
          pv$lower = c(pv$lower, rep(-1e100, n_regressors))
        }
        if (is.null(pv$upper)) {
          pv$upper = c(1e10, 0.99, 1e10, rep(1e100, n_regressors))
        } else if (length(pv$upper) == 3L) {
          pv$upper = c(pv$upper, rep(1e100, n_regressors))
        }
      }
      if (is_quantile) {
        level = sort(unique(quantiles_to_levels(private$.quantiles)))
        if (length(level) > 0L) {
          args$level = level
        }
      }

      fn = getExportedValue("forecTheta", private$.fn)
      pred = invoke(fn, .args = insert_named(args, pv))
      if (!is_quantile) {
        return(insert_named(prediction, list(response = as.numeric(pred$mean))))
      }
      insert_named(prediction, list(quantiles = private$.quantiles_from_intervals(pred)))
    }
  )
)
