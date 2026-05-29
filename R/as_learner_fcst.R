#' @title Convert to a Forecast Learner
#'
#' @description
#' Creates a [RecursiveForecaster] (recursive strategy) or [DirectForecaster] (direct strategy),
#' selected via `strategy`.
#'
#' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
#'   A regression learner (when `lags` is provided) or a graph/PipeOp.
#' @param lags (`integer()` | `NULL`)\cr
#'   The lag values to use for creating lag features.
#' @param strategy (`character(1)`)\cr
#'   Forecasting strategy. One of `"recursive"` (default) or `"direct"`.
#' @param horizons (`integer()` | `NULL`)\cr
#'   Required when `strategy = "direct"`; must be `NULL` when `strategy = "recursive"`.
#'   A single integer `H` is expanded to `1:H`.
#' @param ... (any)\cr
#'   Additional arguments passed to [RecursiveForecaster] or [DirectForecaster].
#' @return [RecursiveForecaster] or [DirectForecaster].
#' @export
#' @examples
#' library(mlr3pipelines)
#'
#' # recursive forecasting (default)
#' flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
#'
#' # recursive with a custom graph
#' graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
#' flrn = as_learner_fcst(graph)
#'
#' # direct forecasting (one model per horizon)
#' flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3, strategy = "direct", horizons = 12)
as_learner_fcst = function(learner, lags = NULL, strategy = "recursive", horizons = NULL, ...) {
  assert_choice(strategy, c("recursive", "direct"))
  if (strategy == "direct") {
    if (is.null(horizons)) {
      error_input("`horizons` is required when strategy = \"direct\".")
    }
    DirectForecaster$new(learner, lags = lags, horizons = horizons, ...)
  } else {
    if (!is.null(horizons)) {
      error_input("`horizons` must be NULL when strategy = \"recursive\".")
    }
    RecursiveForecaster$new(learner, lags = lags, ...)
  }
}
