#' @title Create a Graph to Fit Local Per-Series Forecast Models
#' @name mlr_graphs_fcst.local
#'
#' @description
#' Create a new [Graph][mlr3pipelines::Graph] that wraps `graph` between
#' [`po("fcst.splitkey")`][mlr_pipeops_fcst.splitkey] and
#' [`po("fcst.unitekey")`][mlr_pipeops_fcst.unitekey], fitting one local model per series of a
#' keyed [TaskFcst] instead of one global model pooled across series.
#'
#' All input arguments are cloned and have no references in common with the returned
#' [Graph][mlr3pipelines::Graph].
#'
#' @param graph ([Graph][mlr3pipelines::Graph])\cr
#'   Graph being wrapped between [`po("fcst.splitkey")`][mlr_pipeops_fcst.splitkey] and
#'   [`po("fcst.unitekey")`][mlr_pipeops_fcst.unitekey]. The graph should return `NULL` during
#'   training and a [PredictionFcst] during prediction.
#' @param key (`character(1)`)\cr
#'   Name of the rebuilt series-identity column in the united prediction's `extra` slot, default
#'   `"key"`. Set it to the task's key column name to get predictions column-compatible with
#'   global forecasters such as [RecursiveForecaster].
#' @return [Graph][mlr3pipelines::Graph]
#' @export
#' @examplesIf requireNamespace("forecast", quietly = TRUE)
#' library(mlr3pipelines)
#' library(data.table)
#' dt = CJ(
#'   month = seq(as.Date("2024-01-01"), by = "month", length.out = 36L),
#'   id = factor(c("a", "b"))
#' )
#' dt[, value := rnorm(.N, mean = fifelse(id == "a", 10, 20))]
#' task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
#' flrn = as_learner(ppl("fcst.local", lrn("fcst.ets")))$train(task)
#' forecast(flrn, task, 12L)
pipeline_fcst_local = function(graph, key = "key") {
  PipeOpFcstSplitKey$new() %>>!% graph %>>!% PipeOpFcstUniteKey$new(param_vals = list(key = key))
}

#' @include zzz.R
register_graph("fcst.local", pipeline_fcst_local)
