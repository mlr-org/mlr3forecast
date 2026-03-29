#' @title Select Forecast Lag Features
#'
#' @description
#' [mlr3pipelines::Selector] that selects lag features created by [PipeOpFcstLags].
#' Matches features named `{target}_lag_{i}` where `{target}` is the task's target variable.
#'
#' @return `function`: A [mlr3pipelines::Selector] function.
#' @family Selectors
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' pop = po("fcst.lags", lags = 1:3)
#' new_task = pop$train(list(task))[[1L]]
#' selector_fcst_lags()(new_task)
selector_fcst_lags = function() {
  selector = function(task) {
    pattern = sprintf("^%s_lag_[0-9]+$", task$target_names)
    grep(pattern, task$feature_names, value = TRUE)
  }
  structure(selector, repr = "selector_fcst_lags()", class = c("Selector", "function"))
}
