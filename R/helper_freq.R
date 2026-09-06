infer_freq = function(order) {
  if (length(order) < 2L) {
    return(1L)
  }
  if (!inherits(order, c("Date", "POSIXct", "POSIXlt"))) {
    return(stats::median(diff(sort(order))))
  }
  secs = max(round(as.numeric(stats::median(diff(order)), units = "secs")), 1)
  if (secs == 604800) {
    "week"
  } else if (secs >= 2419200) {
    # >= 28 days, calendar-anchored data (constant day-of-month) gets calendar units,
    # fixed-interval data gets exact day multiples
    n_months = round(secs / 2629800)
    if (uniqueN(mday(order)) == 1L) {
      if (n_months == 3L) {
        "quarter"
      } else if (n_months == 12L) {
        "year"
      } else {
        sprintf("%g month", n_months)
      }
    } else if (secs %% 86400 == 0) {
      sprintf("%g day", secs / 86400)
    } else {
      # neither calendar-anchored nor whole days (e.g. month-end data), magnitude guess
      if (secs <= 2678400) {
        "month"
      } else if (secs <= 7948800) {
        "quarter"
      } else {
        "year"
      }
    }
  } else if (secs %% 86400 == 0) {
    sprintf("%g day", secs / 86400)
  } else if (secs %% 3600 == 0) {
    sprintf("%g hour", secs / 3600)
  } else if (secs %% 60 == 0) {
    sprintf("%g min", secs / 60)
  } else {
    sprintf("%g sec", secs)
  }
}

# `freq` is the grid step throughout: a calendar string for date indices, a number for numeric ones
resolve_step = function(freq, order) {
  freq %??% infer_freq(sort(unique(order)))
}

calendar_months = function(freq) {
  if (!is.character(freq)) {
    return(NA_integer_)
  }
  parts = strsplit1(freq, " ")
  n = if (length(parts) == 2L) suppressWarnings(as.integer(parts[1L])) else 1L
  unit = sub("s$", "", parts[length(parts)])
  per = switch(unit, month = 1L, quarter = 3L, year = 12L, NA_integer_)
  if (is.na(per) || is.na(n)) NA_integer_ else n * per
}

seq_order = function(origin, freq, n) {
  m = calendar_months(freq)
  if (is.na(m)) {
    return(seq(origin, by = freq, length.out = n + 1L)[-1L])
  }
  lt = as.POSIXlt(origin)
  k = (lt$year + 1900L) * 12L + lt$mon + m * seq_len(n)
  yr = k %/% 12L
  mo = k %% 12L + 1L
  eom = mday(as.Date(ISOdate(yr + mo %/% 12L, mo %% 12L + 1L, 1L)) - 1L)
  day = pmin(lt$mday, eom)
  if (inherits(origin, "POSIXct")) {
    tz = attr(origin, "tzone") %??% ""
    ISOdatetime(yr, mo, day, lt$hour, lt$min, lt$sec, tz = tz)
  } else {
    as.Date(ISOdate(yr, mo, day))
  }
}

# --- seasonal period ----------------------------------------------------------------------------
# The seasonal period is the number of observations per cycle. It is a property of the *model*, not
# of the index, so it is only ever a default here: every consumer takes an explicit `period` first
# and falls back to `task$period`, which in turn derives from `freq` unless the task overrides it.

# duration of a seq()-style unit string in seconds, NA if it is not one
freq_seconds = function(x) {
  secs = c(
    sec = 1,
    min = 60,
    hour = 3600,
    day = 86400,
    DSTday = 86400,
    week = 604800,
    month = 2629800,
    quarter = 7889400,
    year = 31557600
  )
  parts = strsplit1(x, " ")
  n_parts = length(parts)
  n = if (n_parts == 2L) suppressWarnings(as.numeric(parts[1L])) else 1
  unit = parts[n_parts]
  if (unit %nin% names(secs)) {
    unit = sub("s$", "", unit)
  }
  if (is.na(n) || n <= 0 || unit %nin% names(secs)) {
    return(NA_real_)
  }
  n * secs[[unit]]
}

#' @title Common Seasonal Periods
#'
#' @description
#' Lists the seasonal periods implied by a frequency, i.e. how many observations fit into each
#' calendar cycle that is longer than a single step. Use it to discover the values accepted by the
#' `period` argument of [as_task_fcst()], the forecast learners, and the seasonal measures.
#'
#' @param x ([TaskFcst] | `character(1)`)\cr
#'   A task, or a `seq()`-compatible frequency string such as `"month"` or `"30 min"`.
#' @param ... (ignored).
#' @return A named `numeric()`, sorted from the shortest cycle to the longest. `c(none = 1)` if the
#'   frequency carries no calendar meaning.
#' @export
#' @examples
#' common_periods("month")
#' common_periods("day")
#' common_periods("30 min")
common_periods = function(x, ...) {
  UseMethod("common_periods")
}

#' @rdname common_periods
#' @export
common_periods.default = function(x, ...) {
  c(none = 1)
}

#' @rdname common_periods
#' @export
common_periods.character = function(x, ...) {
  step = freq_seconds(x)
  if (is.na(step)) {
    return(c(none = 1))
  }
  cycles = c(minute = 60, hour = 3600, day = 86400, week = 604800, year = 31557600)
  periods = cycles / step
  periods = sort(periods[periods > 1])
  if (length(periods) == 0L) c(none = 1) else periods
}

#' @rdname common_periods
#' @export
common_periods.TaskFcst = function(x, ...) {
  common_periods(x$freq)
}

# the cycle a `ts()` user would reach for: the next natural calendar cycle up from the step, e.g. the
# day for sub-daily data and the week for daily data. Cycles shorter than four observations carry no
# seasonal shape, so they are skipped in favour of the next one up.
default_period = function(freq) {
  none = c(none = 1)
  if (!test_string(freq)) {
    return(none)
  }
  step = freq_seconds(freq)
  if (is.na(step)) {
    return(none)
  }
  ladder = c(if (step < 60) "hour", "day", "week", "year")
  periods = common_periods(freq)
  candidates = periods[names(periods) %chin% ladder]
  if (length(candidates) == 0L) {
    return(none)
  }
  long = candidates[candidates >= 4]
  if (length(long) > 0L) long[1L] else candidates[length(candidates)]
}

# a character period ("year", "week") counts how many steps fit into that cycle
resolve_period = function(period, freq) {
  if (is.null(period)) {
    return(default_period(freq))
  }
  if (!is.character(period)) {
    return(period)
  }
  step = if (test_string(freq)) freq_seconds(freq) else NA_real_
  if (is.na(step)) {
    error_input(
      "A character `period` (%s) requires a calendar `freq`, but `freq` is %s.",
      str_collapse(period, quote = "'"),
      if (is.null(freq)) "NULL" else format(freq)
    )
  }
  cycles = map_dbl(period, freq_seconds)
  if (anyNA(cycles)) {
    error_input(
      "Unknown `period` %s. Must be a cycle name such as 'year', 'week' or '2 day'.",
      str_collapse(period[is.na(cycles)], quote = "'")
    )
  }
  set_names(cycles / step, period)
}

# explicit hyperparameter beats the task default, which itself derives from `freq`.
# the measures also score plain regression tasks, which carry neither.
task_period = function(period, task, multiple = FALSE) {
  periods = if (is.null(period)) task$period %??% c(none = 1) else resolve_period(period, task$freq)
  unname(if (multiple) periods else periods[[1L]])
}

#' @export
as.ts.TaskFcst = function(x, ..., period = NULL) {
  if ("freq" %chin% names(list(...))) {
    error_input("`as.ts()` no longer takes `freq`. Use `period` for the seasonal period.")
  }
  if (length(x$col_roles$key) > 0L) {
    error_input("Cannot coerce a multi-series (keyed) task to a single ts object.")
  }
  y = x$data(cols = x$target_names, ordered = TRUE)[[1L]]
  stats::ts(y, frequency = task_period(period, x))
}

resolve_measure_period = function(period, task) {
  max(1L, as.integer(round(task_period(period, task))))
}

to_tsibble_index = function(order, freq) {
  if (is.character(freq)) {
    if (grepl("week", freq, fixed = TRUE)) {
      return(tsibble::yearweek(order))
    }
    if (grepl("month", freq, fixed = TRUE)) {
      return(tsibble::yearmonth(order))
    }
    if (grepl("quarter", freq, fixed = TRUE)) {
      return(tsibble::yearquarter(order))
    }
    if (grepl("year", freq, fixed = TRUE) && inherits(order, c("Date", "POSIXct", "POSIXlt"))) {
      return(year(order))
    }
  }
  order
}
