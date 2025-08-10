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
  cn = names(x)
  assert_choice(target, cn)
  assert_choice(order, cn)
  has_key = length(key) > 0L
  if (has_key) {
    assert_choice(key, cn)
  }

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii) > 0L) {
    warningf("Detected columns with unsupported Inf values in data: %s", str_collapse(names(ii)))
  }

  has_dups = NULL
  dup = if (has_key) {
    x[, .(has_dups = anyDuplicated(get(order)) > 0L), by = key][, any(has_dups)]
  } else {
    anyDuplicated(x[[order]]) > 0L
  }
  if (dup) {
    stopf("`order` values must be unique for each time series.")
  }

  TaskFcst$new(id = id, backend = x, target = target, order = order, key = key, freq = freq, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.tsf = function(x, label = NA_character_, id = deparse1(substitute(x)), ...) {
  force(id)

  assert_data_table(x, min.rows = 1L, min.cols = 1L, col.names = "unique")
  cn = names(x)
  target = cn[length(cn)]
  cn = cn[-length(cn)]
  order = names(keep(x, inherits, c("POSIXct", "Date")))
  if (length(order) != 1L) {
    order = "index"
    x = copy(x)[, (order) := seq_len(.N), by = cn]
  }
  key = setdiff(cn, order)
  if (length(key) > 0L) {
    x[, (key) := as.factor(get(key))]
  }

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii) > 0L) {
    warningf("Detected columns with unsupported Inf values in data: %s", str_collapse(names(ii)))
  }

  TaskFcst$new(
    id = id,
    backend = x,
    target = target,
    order = order,
    key = key,
    freq = attr(x, "frequency"),
    label = label,
    ...
  )
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.ts = function(x, label = NA_character_, id = deparse1(substitute(x)), ...) {
  require_namespaces("tsbox")
  freq = stats::frequency(x)
  freq = switch(
    as.character(freq),
    `365.25` = "daily",
    `52` = "weekly",
    `12` = "monthly",
    `4` = "quarterly",
    `1` = "yearly",
    stopf("Unknown frequency: %s", freq)
  )
  as_task_fcst(
    x = tsbox::ts_dt(x),
    target = "value",
    order = "time",
    freq = freq,
    id = id,
    label = label,
    ...
  )
}
