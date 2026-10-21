#' @title Convert to a Forecast Task
#'
#' @description
#' Convert object to a [TaskFcst].
#' This is a S3 generic. mlr3forecast ships with methods for the following objects:
#'
#' 1. [TaskFcst]: ensure the identity
#' 2. [data.frame()] and [mlr3::DataBackend]: provides an alternative to the constructor of [TaskFcst].
#' 3. `ts`: from base R time series objects (univariate and multivariate).
#'    A frequency of 1, 4, 12, 52, or 365.25 is taken as a yearly, quarterly, monthly, weekly, or daily step.
#'    Any other frequency has no calendar step, so the series gets an integer `index` column as order instead.
#' 4. `zoo` and `xts`: from zoo/xts time series objects.
#'    A `zoo` object with a plain numeric index keeps it as a numeric `index` column as order.
#' 5. `timeSeries`: from Rmetrics timeSeries objects.
#' 6. `tsf`: from tsf format data.
#' 7. `tbl_ts`: from tsibble objects.
#'    The index becomes the order column, where `yearweek`, `yearmonth`, and `yearquarter` indices are converted to
#'    dates.
#'    If `freq` is `NULL`, such an index sets it from the tsibble's interval,
#'    e.g. `"1 month"` for a monthly `yearmonth` index, while other indices infer it like [TaskFcst].
#'    The key variables become key columns, and all measured variables other than `target` become features.
#'
#' @inheritParams mlr3::as_task_regr
#' @template param_order
#' @template param_key
#' @template param_freq
#'
#' @return [TaskFcst].
#' @export
#' @examplesIf mlr3misc::require_namespaces("tsbox", quietly = TRUE)
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
  assert_empty_ellipsis(...)
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
  assert_subset(key, cn)

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
  assert_subset(key, cn)

  ii = which(map_lgl(keep(x, is.double), anyInfinite))
  if (length(ii) > 0L) {
    warning_input("Detected columns with unsupported Inf values in data: %s.", str_collapse(names(ii)))
  }

  if (anyMissing(x[[target]])) {
    error_input("Target column '%s' must not contain missing values.", target)
  }

  if (anyMissing(x[[order]])) {
    error_input("Order column '%s' must not contain missing values.", order)
  }

  if (some(key, function(col) anyMissing(x[[col]]))) {
    error_input("Key column(s) %s must not contain missing values.", str_collapse(key, quote = "'"))
  }

  x = setorderv(as.data.table(x), c(key, order))

  if (anyDuplicated(x, by = c(key, order)) > 0L) {
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
    x[, (order) := seq_len(.N), by = c(cn)]
  }
  key = setdiff(cn, order)
  x[, (key) := map_if(.SD, test_integerish, as.integer), .SDcols = key]

  freq = attr(x, "frequency")
  freq = if (has_order && !is.null(freq)) tsf_frequencies[[freq]] else NULL

  as_task_fcst(x = x, target = target, order = order, key = key, freq = freq, id = id, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task.tsf = function(x, id = deparse1(substitute(x)), clone = FALSE, ...) {
  force(id)
  as_task_fcst(x, id = id, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.ts = function(x, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  force(id)
  ts_freq = stats::frequency(x)
  if (is.null(freq)) {
    freq = switch(
      as.character(ts_freq),
      `365.25` = "day",
      `52` = "week",
      `12` = "month",
      `4` = "quarter",
      `1` = "year",
      NULL
    )
  }
  if (is.null(freq) && ts_freq > 1) {
    warning_input(
      paste0(
        "The frequency %s of the ts object has no calendar step, so the series gets an integer index and its ",
        "seasonal period is not kept. Set `period` on the learners, measures, or pipeops instead."
      ),
      format(ts_freq)
    )
    return(task_fcst_from_ts_index(x, id = id, label = label, ...))
  }
  task_fcst_from_tsbox(x, freq = freq, id = id, label = label, ...)
}

#' @rdname as_task_fcst
#' @export
as_task_fcst.zoo = function(x, freq = NULL, id = deparse1(substitute(x)), label = NA_character_, ...) {
  force(id)
  index = zoo::index(x)
  if (is.numeric(index) && !is.object(index)) {
    return(task_fcst_from_ts_index(zoo::coredata(x), index = index, freq = freq, id = id, label = label, ...))
  }
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
  require_namespaces("tsibble")
  force(id)
  order = tsibble::index_var(x)
  key = tsibble::key_vars(x)
  units = c(yearweek = "week", yearmonth = "month", yearquarter = "quarter")
  unit = units[class(x[[order]])[1L]]
  if (!is.na(unit)) {
    n = unclass(tsibble::interval(x))[[unit]]
    if (is.null(freq) && n > 0) {
      freq = sprintf("%g %s", n, unit)
    }
  }
  x = as.data.table(tsibble::as_tibble(x))
  if (!is.na(unit)) {
    set(x, j = order, value = as.Date(x[[order]]))
  }
  as_task_fcst(x = x, target = target, order = order, key = key, freq = freq, id = id, label = label, ...)
}

task_fcst_from_ts_index = function(x, id, label, index = NULL, freq = NULL, ...) {
  m = as.matrix(x)
  n = nrow(m)
  is_multi = ncol(m) > 1L
  dt = data.table(index = rep(index %??% seq_len(n), ncol(m)), value = as.numeric(m))
  if (is_multi) {
    set(dt, j = "id", value = rep(colnames(m), each = n))
  }
  dt = dt[!is.na(dt$value)]
  key = if (is_multi) "id" else character()
  as_task_fcst(x = dt, target = "value", order = "index", key = key, freq = freq, id = id, label = label, ...)
}

task_fcst_from_tsbox = function(x, freq, id, label, ...) {
  require_namespaces("tsbox")
  x = tsbox::ts_dt(x)
  is_multi = "id" %chin% names(x)
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
