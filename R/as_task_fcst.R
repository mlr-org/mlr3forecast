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
#' 5. `timeSeries`: from Rmetrics timeSeries objects.
#' 6. `tsf`: from tsf format data.
#' 7. `tbl_ts`: from tsibble objects.
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
  if (is.null(names(x))) {
    map(x, as_task_fcst, ...)
  } else {
    imap(x, function(x, id) as_task_fcst(x, id = id, ...))
  }
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

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii) > 0L) {
    warning_input("Detected columns with unsupported Inf values in data: %s", str_collapse(names(ii)))
  }

  if (anyMissing(x[[target]])) {
    error_input("Target column '%s' must not contain missing values", target)
  }

  if (anyMissing(x[[order]])) {
    error_input("Order column '%s' must not contain missing values", order)
  }

  x = setorderv(as.data.table(x), c(key, order))

  dup = if (has_key) {
    anyDuplicated(x, by = c(key, order)) > 0L
  } else {
    anyDuplicated(x[[order]]) > 0L
  }
  if (dup) {
    error_input("`order` values must be unique for each time series.")
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
  has_order = length(order) == 1L
  x = copy(x)
  setattr(x, "class", setdiff(class(x), "tsf"))
  if (!has_order) {
    order = "index"
    x[, (order) := seq_len(.N), by = cn]
  }
  key = setdiff(cn, order)
  for (k in key) {
    set(x, j = k, value = as.factor(x[[k]]))
  }

  freq = attr(x, "frequency")
  freq = if (has_order && !is.null(freq)) tsf_to_seq(freq) else NULL

  as_task_fcst(x = x, target = target, order = order, key = key, freq = freq, id = id, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.ts = function(x, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  force(id)
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
  task_fcst_from_tsbox(x, freq = freq, id = id, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.zoo = function(x, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  force(id)
  task_fcst_from_tsbox(x, freq = freq, id = id, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.timeSeries = function(x, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  force(id)
  task_fcst_from_tsbox(x, freq = freq, id = id, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.tbl_ts = function(x, target, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  force(id)
  require_namespaces(c("tsbox", "tsibble"))
  order = tsibble::index_var(x)
  key = tsibble::key_vars(x)
  x = tsbox::ts_dt(x)
  as_task_fcst(x = x, target = target, order = order, key = key, freq = freq, id = id, label = label, ...)
}

task_fcst_from_tsbox = function(x, freq, id, label, ...) {
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
