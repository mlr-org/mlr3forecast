#' @title Weighted Prediction Averaging for Forecasts
#' @name mlr_pipeops_fcst.avg
#'
#' @description
#' Performs (weighted) averaging of forecast [PredictionFcst]s, mirroring [mlr3pipelines::PipeOpRegrAvg] but
#' preserving the forecast prediction type, which plain `regravg` would drop. The output is a [PredictionFcst] that
#' keeps the time index and key columns (carried in the `extra` slot with explicit column roles), so `$order`, `$key`,
#' [autoplot.PredictionFcst()], and forecast `task_type` inference keep working through the ensemble.
#'
#' Connect it to several [PipeOpLearner][mlr3pipelines::PipeOpLearner] outputs (classical forecast learners or
#' [RecursiveForecaster] / [DirectForecaster]) to average their forecasts.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpRegrAvg].
#'
#' @export
#' @examplesIf requireNamespace("forecast", quietly = TRUE)
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' graph = gunion(list(
#'   po("learner", lrn("fcst.auto_arima"), id = "arima"),
#'   po("learner", lrn("fcst.ets"), id = "ets")
#' )) %>>%
#'   po("fcst.avg")
#' flrn = as_learner(graph)$train(task)
#' forecast(flrn, task, 12L)
PipeOpFcstAvg = R6Class(
  "PipeOpFcstAvg",
  inherit = PipeOpRegrAvg,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param innum (`numeric(1)`)\cr
    #'   Number of input channels. Default `0` creates a vararg channel taking an arbitrary number of inputs.
    #' @param collect_multiplicity (`logical(1)`)\cr
    #'   If `TRUE`, the single input is a [Multiplicity][mlr3pipelines::Multiplicity] collecting channel. Requires
    #'   `innum = 0`. Default `FALSE`.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.avg"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would otherwise be set during
    #'   construction. Default `list()`.
    initialize = function(innum = 0L, collect_multiplicity = FALSE, id = "fcst.avg", param_vals = list()) {
      super$initialize(
        innum = innum,
        collect_multiplicity = collect_multiplicity,
        id = id,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        tags = "fcst"
      )
      # retype channels to PredictionFcst so the output stays a forecast and task_type infers as "fcst";
      # PipeOpRegrAvg hardcodes prediction_type = "PredictionRegr", so it cannot be passed through
      ptype = if (collect_multiplicity) "[PredictionFcst]" else "PredictionFcst"
      set(self$input, j = "predict", value = ptype)
      set(self$output, j = "predict", value = "PredictionFcst")
    }
  ),

  private = list(
    weighted_avg_predictions = function(inputs, weights, row_ids, truth) {
      extra = inputs[[1L]]$data$extra
      col_roles = fcst_common_col_roles(map(inputs, "data"))
      obs_weights = inputs[[1L]]$data$weights
      quantiles = map(inputs, function(x) x$data$quantiles)
      if (every(quantiles, is.null)) {
        # reuse PipeOpRegrAvg's response/se aggregation, re-wrapped with the shared time index and keys
        prediction = super$weighted_avg_predictions(inputs, weights, row_ids, truth)
        return(PredictionFcst$new(
          row_ids = row_ids,
          truth = truth,
          response = prediction$response,
          se = prediction$data$se,
          weights = obs_weights,
          extra = extra,
          col_roles = col_roles
        ))
      }
      if (some(quantiles, is.null)) {
        error_input("Cannot average predictions: some predict quantiles, others do not.")
      }
      # weighted per-level average (Vincentization) keeps the combined quantiles monotone
      probs = attr(quantiles[[1L]], "probs")
      if (!every(quantiles[-1L], function(q) identical(attr(q, "probs"), probs))) {
        error_input("Cannot average quantile predictions: incoming predictions use different quantile probabilities.")
      }
      averaged = quantiles[[1L]] * weights[[1L]]
      if (length(quantiles) > 1L) {
        for (i in seq.int(2L, length(quantiles))) {
          averaged = averaged + quantiles[[i]] * weights[[i]]
        }
      }
      response = attr(quantiles[[1L]], "response")
      setattr(averaged, "probs", probs)
      setattr(averaged, "response", probs[match(response, sprintf("q%g", probs))])
      PredictionFcst$new(
        row_ids = row_ids,
        truth = truth,
        quantiles = averaged,
        weights = obs_weights,
        extra = extra,
        col_roles = col_roles
      )
    }
  )
)

#' @include zzz.R
register_po("fcst.avg", PipeOpFcstAvg)
