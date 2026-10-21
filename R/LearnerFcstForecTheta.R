#' @title Abstract class for forecTheta package learners
#' @keywords internal
#' @include LearnerFcst.R
LearnerFcstForecTheta = R6Class(
  "LearnerFcstForecTheta",
  inherit = LearnerFcst,
  private = list(
    .seasonal = TRUE,

    .train = function(task) {
      super$.train(task)
      pv = private$.train_values()
      y = private$.as_ts(task)
      # a seasonal forecTheta fit returns an empty forecast for h = 1, so fit with a two-step placeholder
      args = list(y = y, h = 2L, level = NULL)

      xreg = private$.xreg(task)
      if (!is.null(xreg)) {
        args$xreg = rbind(xreg, matrix(0, 2L, ncol(xreg)))
      }

      fn = getExportedValue("forecTheta", private$.fn)
      model = invoke(fn, .args = insert_named(args, pv))
      context = private$.set_context(model, task)
      insert_named(context, list(xreg = xreg, params = pv))
    },

    .fitted = function() {
      model = self$native_model
      fitted = if (is.null(model$lambda)) model$fitted else forecast::InvBoxCox(model$fitted, model$lambda)
      as.numeric(fitted)
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

      # same h = 1 limitation as in train, so forecast at least two steps and trim
      n = task$nrow
      h = max(n, 2L)
      args = list(y = model$y, h = h, level = NULL)
      if (!is.null(self$model$xreg)) {
        newxreg = private$.newxreg(task)
        args$xreg = rbind(self$model$xreg, newxreg, matrix(0, h - n, ncol(newxreg)))
        n_regressors = length(pv$par_ini) - 3L
        pv$lower = pv$lower %??% c(-1e10, 0.1, 1)
        if (length(pv$lower) == 3L) {
          pv$lower = c(pv$lower, rep(-1e100, n_regressors))
        }
        pv$upper = pv$upper %??% c(1e10, 0.99, 1e10)
        if (length(pv$upper) == 3L) {
          pv$upper = c(pv$upper, rep(1e100, n_regressors))
        }
      }
      if (is_quantile) {
        level = quantiles_to_levels(private$.quantiles)
        if (length(level) > 0L) {
          args$level = level
        }
      }

      fn = getExportedValue("forecTheta", private$.fn)
      pred = invoke(fn, .args = insert_named(args, pv))
      keep = seq_len(n)
      if (!is_quantile) {
        return(insert_named(prediction, list(response = as.numeric(pred$mean)[keep])))
      }
      pred$mean = as.numeric(pred$mean)[keep]
      pred$lower = as.matrix(pred$lower)[keep, , drop = FALSE]
      pred$upper = as.matrix(pred$upper)[keep, , drop = FALSE]
      insert_named(prediction, list(quantiles = private$.quantiles_from_intervals(pred)))
    }
  )
)
