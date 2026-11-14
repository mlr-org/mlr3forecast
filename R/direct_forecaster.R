#' @title Create a Direct Forecast Learner
#'
#' @description
#' Function to create a [DirectForecaster] object. This is the recommended way to construct a direct forecaster. It is a
#' thin wrapper around `DirectForecaster$new()`.
#'
#' A direct forecaster trains a separate regression model per forecast horizon, so predictions never feed back into one
#' another (no error accumulation). For the recursive strategy (a single iterated model) see [recursive_forecaster()].
#'
#' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
#'   A regression learner or a graph/PipeOp.
#'   The model for horizon `h` shifts the graph's lag and rolling features `h - 1` steps into the past.
#' @param lags (`integer()` | `NULL`)\cr
#'   The base lag values.
#'   If provided, `po("fcst.lags", lags = lags)` is added in front of `learner`,
#'   and its parameter `fcst.lags.lags` can be tuned via [mlr3tuning::AutoTuner].
#'   If `NULL`, the graph should contain its own lag or rolling features.
#' @param horizons (`integer()`)\cr
#'   Either a single integer `H` (expanded to `1:H`) or an integer vector of specific horizons. One model is trained
#'   per horizon.
#' @param id (`character(1)` | `NULL`)\cr
#'   Identifier, default `NULL`, which uses the id of `learner` with the suffix `".direct"`.
#' @param param_vals (named `list()`)\cr
#'   Hyperparameter values applied to every horizon model. Per-horizon hyperparameters are not currently supported.
#' @param predict_type (`character(1)` | `NULL`)\cr
#'   The predict type, default `NULL`.
#' @param clone_graph (`logical(1)`)\cr
#'   Whether to clone the graph, default `TRUE`.
#'   If `lags` is provided, a new graph is built in any case.
#' @return [DirectForecaster].
#' @export
#' @examplesIf mlr3misc::require_namespaces("rpart", quietly = TRUE)
#' library(mlr3pipelines)
#'
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#'
#' # one model per horizon
#' flrn = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#'
#' # graph: the same graph also works with recursive_forecaster()
#' graph = po("fcst.lags", lags = 1:3) %>>%
#'   po("fcst.rolling", window_sizes = 6L) %>>%
#'   lrn("regr.rpart")
#' flrn = direct_forecaster(graph, horizons = length(split$test))
direct_forecaster = function(
  learner,
  lags = NULL,
  horizons,
  id = NULL,
  param_vals = list(),
  predict_type = NULL,
  clone_graph = TRUE
) {
  DirectForecaster$new(
    learner = learner,
    lags = lags,
    horizons = horizons,
    id = id,
    param_vals = param_vals,
    predict_type = predict_type,
    clone_graph = clone_graph
  )
}
