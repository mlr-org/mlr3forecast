#' @title Convert to a Forecast Task
#'
#' @description
#' Convert object to a [TaskFcst].
#' This is a S3 generic. mlr3forecast ships with methods for the following objects:
#'
#' 1. [TaskFcst]: ensure the identity
#' 2. [data.frame()] and [mlr3::DataBackend]: provides an alternative to the constructor of [TaskFcst].
#'
#' @inheritParams mlr3::as_task_regr
#' @template param_order
#' @template param_key
#' @template param_freq
#'
#' @return [TaskFcst].
#' @export
#' @examplesIf requireNamespace("tsbox", quietly = TRUE)
#' library(data.table)
#' airpassengers = tsbox::ts_dt(AirPassengers)
#' setnames(airpassengers, c("month", "passengers"))
#' as_task_fcst(airpassengers, target = "passengers", order = "month", freq = "monthly")
as_task_fcst = function(x, ...) {
  UseMethod("as_task_fcst")
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.TaskFcst = function(x, clone = FALSE, ...) {
  if (clone) x$clone() else x
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.DataBackend = function(
  x,
  target = NULL,
  order = character(),
  key = character(),
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
) {
  force(id)

  cn = x$colnames
  assert_choice(target, cn)
  assert_choice(order, cn)
  if (length(key) > 0L) {
    assert_choice(key, cn)
  }

  TaskFcst$new(id = id, backend = x, target = target, order = order, key = key, freq = freq, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.data.frame = function(
  x,
  target = NULL,
  order = character(),
  key = character(),
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
) {
  force(id)

  assert_data_frame(x, min.rows = 1L, min.cols = 1L, col.names = "unique")
  nms = names(x)
  assert_choice(target, nms)
  assert_choice(order, nms)
  if (length(key) > 0L) {
    assert_choice(key, nms)
  }

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii) > 0L) {
    warningf("Detected columns with unsupported Inf values in data: %s", str_collapse(names(ii)))
  }

  TaskFcst$new(id = id, backend = x, target = target, order = order, key = key, freq = freq, label = label, ...)
}
