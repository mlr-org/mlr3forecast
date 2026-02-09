#' @title Convert to a Forecast Task
#'
#' @description
#' Convert object to a [TaskFcst].
#' This is a S3 generic. mlr3forecast ships with methods for the following objects:
#'
#' 1. [TaskFcst]: ensure the identity
#' 2. [data.frame()] and [mlr3::DataBackend]: provides an alternative to the constructor of [TaskFcst].
#' 3. `ts`: from base R time series objects (univariate and multivariate).
#' 4. `zoo` and `xts`: from zoo/xts time series objects.
#' 5. `tsf`: from tsf format data.
#' 6. `tbl_ts`: from tsibble objects.
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
#' as_task_fcst(airpassengers, target = "passengers", order = "month", freq = "month")
as_task_fcst = function(x, ...) {
  UseMethod("as_task_fcst")
}

#' @rdname as_task_fcst
#' @export
as_tasks_fcst = function(x, ...) {
  UseMethod("as_tasks_fcst")
}

#' @rdname as_task_fcst
#' @export
as_tasks_fcst.default = function(x, ...) {
  list(as_task_fcst(x, ...))
}

#' @rdname as_task_fcst
#' @export
as_tasks_fcst.list = function(x, ...) {
  lapply(x, as_task_fcst, ...)
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
  target,
  order,
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
    assert_subset(key, cn)
  }

  TaskFcst$new(id = id, backend = x, target = target, order = order, key = key, freq = freq, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.data.frame = function(
  x,
  target,
  order,
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
    assert_subset(key, cn)
  }

  if (anyNA(x[[target]])) {
    error_input("`target` must not contain `NA` values.")
  }

  has_dups = NULL
  if (has_key) {
    dup = setDT(x)[, list(has_dups = anyDuplicated(get(order)) > 0L), by = key][, any(has_dups)]
  } else {
    dup = anyDuplicated(x[[order]]) > 0L
  }
  if (dup) {
    error_input("`order` values must be unique for each time series.")
  }

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii) > 0L) {
    warning_input("Detected columns with unsupported Inf values in data: %s", str_collapse(names(ii)))
  }

  TaskFcst$new(id = id, backend = x, target = target, order = order, key = key, freq = freq, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.tsf = function(x, id = deparse1(substitute(x)), label = NA_character_, ...) {
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
  for (k in key) {
    set(x, j = k, value = as.factor(x[[k]]))
  }

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii) > 0L) {
    warning_input("Detected columns with unsupported Inf values in data: %s", str_collapse(names(ii)))
  }

  freq = attr(x, "frequency")
  freq = freq %??% tsf_to_seq(freq)

  TaskFcst$new(
    id = id,
    backend = x,
    target = target,
    order = order,
    key = key,
    freq = freq,
    label = label,
    ...
  )
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.ts = function(x, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  require_namespaces("tsbox")
  if (is.null(freq)) {
    freq = stats::frequency(x)
    freq = switch(
      as.character(freq),
      `365.25` = "day",
      `52` = "week",
      `12` = "month",
      `4` = "quarter",
      `1` = "year",
      freq
    )
  }
  is_mts = inherits(x, "mts")
  x = tsbox::ts_dt(x)
  if (is_mts) {
    set(x, j = "id", value = as.factor(x$id))
  }
  as_task_fcst(
    x = x,
    target = "value",
    order = "time",
    key = if (is_mts) "id" else character(),
    freq = freq,
    id = id,
    label = label,
    ...
  )
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.zoo = function(x, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  require_namespaces("tsbox")
  x = tsbox::ts_dt(x)
  is_multi = "id" %in% names(x)
  if (is_multi) {
    set(x, j = "id", value = as.factor(x$id))
  }
  as_task_fcst(
    x = x,
    target = "value",
    order = "time",
    key = if (is_multi) "id" else character(),
    freq = freq,
    id = id,
    label = label,
    ...
  )
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.tbl_ts = function(x, target, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  require_namespaces(c("tsbox", "tsibble"))
  order = tsibble::index_var(x)
  key = tsibble::key_vars(x)
  x = tsbox::ts_dt(x)
  as_task_fcst(
    x = x,
    target = target,
    order = order,
    key = key,
    freq = freq,
    id = id,
    label = label,
    ...
  )
}
