#' @title Convert to a Forecast Task
#'
#' @description
#' Convert object to a [TaskFcst].
#' This is a S3 generic. mlr3forecast ships with methods for the following objects:
#'
#' 1. [TaskRegr]: ensure the identity
#' 2. [data.frame()] and [DataBackend]: provides an alternative to the constructor of [TaskFcst].
#'
#' @inheritParams mlr3::as_task
#'
#' @return [TaskFcst].
#' @export
#' @examples
#' as_task_fcst(tsbox::ts_dt(AirPassengers), target = "value", index = "time")
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
as_task_fcst.DataBackend = function(x, target = NULL, index = NULL, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) { # nolint
  force(id)

  assert_choice(target, x$colnames)
  assert_choice(index, x$colnames)

  TaskFcst$new(
    id = id, backend = x, target = target, index = index, target = target, label = label, ...
  )
}

#' @rdname as_task_fcst
#' @template param_target
#' @param id (`character(1)`)\cr
#'   Id for the new task.
#'   Defaults to the (deparsed and substituted) name of the data argument.
#' @param index (`character(1)`)\cr
#'   Name of the column in the data containing the index.
#' @param freq (`character(1)`)\cr
#'   Frequency of the time series.
#' @template param_label
#' @export
as_task_fcst.data.frame = function(x, target = NULL, index = NULL, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) { # nolint
  force(id)

  assert_data_frame(x, min.rows = 1L, min.cols = 1L, col.names = "unique")
  assert_choice(target, names(x))
  assert_choice(index, names(x))

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii)) {
    warningf("Detected columns with unsupported Inf values in data: %s", str_collapse(names(ii)))
  }

  TaskFcst$new(id = id, backend = x, target = target, index = index, freq = freq, label = label)
}
