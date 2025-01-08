#' @title ETS
#'
#' @name mlr_learners_fcst.ets
#'
#' @description
#' ETS model.
#' Calls [forecast::ets()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.ets
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018automatic")`
#'
#' @export
#' @template seealso_learner
LearnerFcstEts = R6Class("LearnerFcstEts",
  inherit = LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps()

      super$initialize(
        id = "fcst.ets",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "logical", "integer", "numeric"),
        packages = c("mlr3forecast", "forecast"),
        label = "ETS",
        man = "mlr3forecast::mlr_learners_fcst.ets"
      )
    }
  ),

  private = list(
    .max_index = NULL,

    .train = function(task) {
      if ("ordered" %nin% task$properties) {
        stopf("%s learner requires an ordered task.", self$id)
      }
      private$.max_index = max(task$data(cols = task$col_roles$order)[[1L]])
      pv = self$param_set$get_values(tags = "train")
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }

      invoke(forecast::ets,
        y = stats::ts(task$data(cols = task$target_names)[[1L]]),
        .args = pv
      )
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

      args = list(h = length(task$row_ids))
      if (is_quantile) {
        args = insert_named(args, list(level = quantiles_to_level(private$.quantiles)))
      }
      pred = invoke(forecast::forecast, self$model, .args = args)

      if (!is_quantile) {
        return(list(response = as.numeric(pred$mean)))
      }

      # might not be robust enough with position instead of name
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

#' @include zzz.R
register_learner("fcst.ets", LearnerFcstEts)
