#' @title Create a Direct Forecast Learner
#'
#' @description
#' Function to create a [DirectForecaster] object. This is the recommended way to construct a direct forecaster; it is a
#' thin wrapper around `DirectForecaster$new()`.
#'
#' A direct forecaster trains a separate regression model per forecast horizon, so predictions never feed back into one
#' another (no error accumulation). For the recursive strategy (a single iterated model) see [recursive_forecaster()].
#'
#' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
#'   A regression learner or a graph/PipeOp (without [PipeOpFcstLags]).
#' @param lags (`integer()`)\cr
#'   The base lag values. Exposed in `$param_set` as `lags`, so it can be tuned via [mlr3tuning::AutoTuner].
#' @param horizons (`integer()`)\cr
#'   Either a single integer `H` (expanded to `1:H`) or an integer vector of specific horizons. One model is trained
#'   per horizon.
#' @param id (`character(1)` | `NULL`)\cr
#'   Identifier, default `NULL` (auto-generated from the learner id).
#' @param param_vals (named `list()`)\cr
#'   Hyperparameter values applied to every horizon model. Per-horizon hyperparameters are not currently supported.
#' @param predict_type (`character(1)` | `NULL`)\cr
#'   The predict type, default `NULL`.
#' @return [DirectForecaster].
#' @export
#' @examples
#' library(mlr3pipelines)
#'
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#'
#' # one model per horizon
#' flrn = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
direct_forecaster = function(learner, lags, horizons, id = NULL, param_vals = list(), predict_type = NULL) {
  DirectForecaster$new(
    learner = learner,
    lags = lags,
    horizons = horizons,
    id = id,
    param_vals = param_vals,
    predict_type = predict_type
  )
}
