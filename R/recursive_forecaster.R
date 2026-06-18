#' @title Create a Recursive Forecast Learner
#'
#' @description
#' Function to create a [RecursiveForecaster] object. This is the recommended way to construct a recursive forecaster;
#' it is a thin wrapper around `RecursiveForecaster$new()`.
#'
#' A recursive forecaster trains a single regression model and forecasts iteratively one step ahead, feeding each
#' prediction back as a lag/rolling feature for the next step. For the direct strategy (one model per horizon) see
#' [direct_forecaster()].
#'
#' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
#'   A regression learner (when `lags` is provided) or a graph/PipeOp.
#' @param lags (`integer()` | `NULL`)\cr
#'   The lag values to use for creating lag features. If provided, `learner` is wrapped with
#'   `po("fcst.lags", lags = lags)`. If `NULL`, `learner` must be a [mlr3pipelines::Graph] or [mlr3pipelines::PipeOp].
#' @param id (`character(1)` | `NULL`)\cr
#'   Identifier, default `NULL` (auto-generated).
#' @param param_vals (named `list()`)\cr
#'   List of hyperparameter settings.
#' @param predict_type (`character(1)` | `NULL`)\cr
#'   The predict type, default `NULL`.
#' @param clone_graph (`logical(1)`)\cr
#'   Whether to clone the graph, default `TRUE`.
#' @return [RecursiveForecaster].
#' @export
#' @examples
#' library(mlr3pipelines)
#'
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#'
#' # simple: wrap a regression learner with lag features
#' flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#'
#' # graph: custom preprocessing pipeline
#' graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
#' flrn = recursive_forecaster(graph)
recursive_forecaster = function(
  learner,
  lags = NULL,
  id = NULL,
  param_vals = list(),
  predict_type = NULL,
  clone_graph = TRUE
) {
  RecursiveForecaster$new(
    learner = learner,
    lags = lags,
    id = id,
    param_vals = param_vals,
    predict_type = predict_type,
    clone_graph = clone_graph
  )
}
