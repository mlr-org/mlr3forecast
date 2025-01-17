#' @title Convert to a Forecast Task
#'
#' @description
#' Convert object to a [TaskRegr].
#' This is a S3 generic. mlr3forecast ships with methods for the following objects:
#'
#' 1. [TaskRegr]: ensure the identity
#' 2. [data.frame()] and [DataBackend]: provides an alternative to the constructor of [TaskRegr].
#'
#' @inheritParams mlr3::as_task
#' @param index (`character(1)`) the column name of the index.
#' @param key (`character(1)`) the column name of the key.
#'
#' @return [mlr3::TaskRegr].
#' @export
#' @examplesIf requireNamespace("tsbox", quietly = TRUE)
#' airpassengers = tsbox::ts_dt(AirPassengers)
#' data.table::setnames(airpassengers, c("date", "passengers"))
#' as_task_fcst(airpassengers, target = "passengers", index = "date")
as_task_fcst = function(x, ...) {
  UseMethod("as_task_fcst")
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.DataBackend = function(x, target = NULL, order = character(), key = character(), id = deparse1(substitute(x)), label = NA_character_, ...) { # nolint
  force(id)

  cn = x$colnames
  assert_choice(target, cn)
  assert_choice(order, cn)
  if (length(key) > 0L) {
    assert_choice(key, cn)
  }

  task = TaskFcst$new(id = id, backend = x, target = target, order = order, label = label, ...)
  task$set_col_roles(key, add = "key")
  task
}

#' @rdname as_task_fcst
#' @template param_target
#' @param id (`character(1)`)\cr
#'   Id for the new task.
#'   Defaults to the (deparsed and substituted) name of the data argument.
#' @param index (`character(1)`)\cr
#'   Name of the column in the data containing the index.
#' @template param_label
#' @export
as_task_fcst.data.frame = function(x, target = NULL, order = character(), key = character(), id = deparse1(substitute(x)), label = NA_character_, ...) { # nolint
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

  task = TaskFcst$new(id = id, backend = x, target = target, order = order, label = label, ...)
  task$set_col_roles(key, add = "key")
  task
}
