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
    target = assert_string(task$target_names)
    pattern = sprintf("^%s_lag_[0-9]+$", target)
    grep(pattern, task$feature_names, value = TRUE)
  }
  structure(selector, repr = "selector_fcst_lags()", class = c("Selector", "function"))
}

#' @title Select Forecast Rolling Features
#'
#' @description
#' [mlr3pipelines::Selector] that selects rolling-window features created by [PipeOpFcstRolling].
#' Matches features named `{target}_roll_{fun}_{size}` where `{target}` is the task's target variable
#' and `{fun}` is one of the aggregation functions supported by [PipeOpFcstRolling].
#'
#' @return `function`: A [mlr3pipelines::Selector] function.
#' @family Selectors
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' pop = po("fcst.rolling", funs = c("mean", "sd"), window_sizes = c(3L, 12L))
#' new_task = pop$train(list(task))[[1L]]
#' selector_fcst_rolling()(new_task)
selector_fcst_rolling = function() {
  selector = function(task) {
    target = assert_string(task$target_names)
    pattern = sprintf("^%s_roll_(mean|median|sd|min|max|sum)_([0-9]+|expanding)$", target)
    grep(pattern, task$feature_names, value = TRUE)
  }
  structure(selector, repr = "selector_fcst_rolling()", class = c("Selector", "function"))
}
