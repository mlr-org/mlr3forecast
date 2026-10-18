# seconds per freq unit, calendar units use their average length, e.g. a month is 365.25 / 12 days
unit_secs = c(
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

infer_freq = function(order) {
  order = sort(unique(order))
  if (!inherits(order, c("Date", "POSIXct"))) {
    return(numeric_step(order))
  }
  secs = max(round(as.numeric(stats::median(diff(order)), units = "secs")), 1)
  day = unit_secs[["day"]]
  long = secs >= 28 * day
  if (!long && secs %% day == 0 && keeps_local_clock(order)) {
    sprintf("%.0f DSTday", secs / day)
  } else if (long && !anyNA(grid_steps(order, rep.int(1L, length(order)), "month"))) {
    # calendar-anchored data (constant day-of-month) gets calendar units
    n_months = round(secs / unit_secs[["month"]])
    if (n_months == 3L) {
      "quarter"
    } else if (n_months == 12L) {
      "year"
    } else {
      sprintf("%g month", n_months)
    }
  } else if (long && secs %% day != 0) {
    # neither calendar-anchored nor whole days, magnitude guess
    if (secs <= 31 * day) {
      "month"
    } else if (secs <= 92 * day) {
      "quarter"
    } else {
      "year"
    }
  } else {
    # fixed-interval data gets exact multiples of the largest unit that divides the step
    units = unit_secs[c("week", "day", "hour", "min", "sec")]
    unit = names(units)[secs %% units == 0][1L]
    sprintf("%.0f %s", secs / units[[unit]], unit)
  }
}

# pooling the series would mix their anchors, e.g. monthly series dated on the 1st and the 15th look 14 days apart
series_steps = function(order, series) {
  series = keep(unique(split(order, series)), function(x) uniqueN(x) > 1L)
  unique(map(series, infer_freq))
}

numeric_step = function(order) {
  gaps = diff(order)
  if (!test_integerish(gaps)) {
    return(stats::median(gaps))
  }
  gcd = function(a, b) if (b == 0) a else gcd(b, a %% b)
  step = Reduce(gcd, unique(round(gaps)))
  if (is.integer(order)) as.integer(step) else step
}

infer_task_freq = function(order, series) {
  steps = series_steps(order, series)
  if (length(steps) == 0L) {
    if (is.numeric(order)) {
      return(if (is.integer(order)) 1L else 1)
    }
    error_input("Cannot infer `freq` without a series of at least two observations. Set `freq` explicitly.")
  }
  if (length(steps) > 1L) {
    error_input(
      "Cannot infer `freq`, the series have different steps (%s). A task holds series of a single step.",
      str_collapse(map_chr(steps, format))
    )
  }
  step = steps[[1L]]
  n_off = count_missing(grid_steps(order, series, step))
  if (n_off > 0L) {
    error_input(
      paste0(
        "Cannot infer `freq`, the order column is irregular: %i observation(s) are not a whole number of the ",
        "inferred steps (%s) after the first observation of their series. Set `freq` explicitly."
      ),
      n_off,
      format(step)
    )
  }
  step
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

# days since 1970-01-01 without strptime (Hinnant's days_from_civil)
days_from_civil = function(year, month, day) {
  year = year - (month <= 2L)
  era = year %/% 400L
  yoe = year - era * 400L
  doy = (153L * ((month + 9L) %% 12L) + 2L) %/% 5L + day - 1L
  doe = yoe * 365L + yoe %/% 4L - yoe %/% 100L + doy
  era * 146097L + doe - 719468L
}

days_in_month = function(year, month) {
  days_from_civil(year + month %/% 12L, month %% 12L + 1L, 1L) - days_from_civil(year, month, 1L)
}

civil_parts = function(x) {
  lt = as.POSIXlt(x)
  list(year = lt$year + 1900L, month = lt$mon + 1L, day = lt$mday, clock = lt$hour * 3600 + lt$min * 60 + lt$sec)
}

is_month_end = function(parts) {
  out = parts$day >= 28L
  ii = which(out)
  out[ii] = parts$day[ii] == days_in_month(parts$year[ii], parts$month[ii])
  out
}

# a calendar grid is anchored on the month end if every observation is one, else on the largest day-of-month
grid_anchor = function(order, freq) {
  if (is.na(calendar_months(freq))) {
    return(NA_integer_)
  }
  parts = civil_parts(order)
  if (all(is_month_end(parts))) 31L else max(parts$day)
}

keeps_local_clock = function(order) {
  if (!inherits(order, "POSIXct")) {
    return(FALSE)
  }
  tz = attr(order, "tzone")[1L] %??% ""
  parts = civil_parts(order)
  offsets = format(as.POSIXct(sprintf("%i-%s-01", parts$year[1L], c("01", "07")), tz = tz), "%z")
  uniqueN(offsets) > 1L && uniqueN(parts$clock) == 1L
}

seq_order = function(origin, freq, n, anchor = NA_integer_) {
  m = calendar_months(freq)
  if (is.na(m)) {
    return(seq(origin, by = freq, length.out = n + 1L)[-1L])
  }
  parts = civil_parts(origin)
  k = parts$year * 12L + parts$month - 1L + m * seq_len(n)
  yr = k %/% 12L
  mo = k %% 12L + 1L
  first = days_from_civil(yr, mo, 1L)
  day = pmin(if (is.na(anchor)) parts$day else anchor, days_in_month(yr, mo))
  if (inherits(origin, "POSIXct")) {
    tz = attr(origin, "tzone") %??% ""
    ISOdatetime(yr, mo, day, hour(origin), minute(origin), second(origin), tz = tz)
  } else {
    structure(as.double(first + day - 1L), class = "Date")
  }
}

grid_steps = function(order, series, freq) {
  first = match(series, series)
  m = calendar_months(freq)
  is_dst_day = grepl("DSTday", freq, fixed = TRUE) && inherits(order, "POSIXct")
  if (!is.na(m) || is_dst_day) {
    parts = civil_parts(order)
    on_clock = parts$clock == parts$clock[first]
  }
  if (!is.na(m)) {
    months = parts$year * 12L + parts$month
    months = months - months[first]
    eom = is_month_end(parts)
    by_series = data.table(series = series, day = parts$day, other = as.integer(!eom))
    by_series = by_series[, lapply(.SD, max), by = "series"]
    anchor = fifelse(by_series$other == 0L, 31L, by_series$day)[series]
    steps = months / m
    on_grid = on_clock & (parts$day == anchor | eom) & months %% m == 0L
  } else if (is_dst_day) {
    days = days_from_civil(parts$year, parts$month, parts$day)
    steps = (days - days[first]) / (unit_seconds(freq) / unit_secs[["day"]])
    on_grid = on_clock & steps == round(steps)
  } else {
    gap = as.numeric(order) - as.numeric(order[first])
    if (is.character(freq)) {
      gap = gap * if (inherits(order, "Date")) unit_secs[["day"]] else 1
      freq = unit_seconds(freq)
    }
    steps = gap / freq
    on_grid = abs(steps - round(steps)) < 1e-8
  }
  replace(round(steps), !on_grid, NA_real_)
}

task_resolve_freq = function(task, freq) {
  order_col = task$col_roles$order
  key_cols = task$col_roles$key
  dt = task$data(cols = c(key_cols, order_col))
  setorderv(dt, c(key_cols, order_col))
  order = dt[[order_col]]
  series = if (length(key_cols) > 0L) rleidv(dt, key_cols) else rep.int(1L, nrow(dt))
  if (is.null(freq)) {
    return(infer_task_freq(order, series))
  }
  if (is.integer(order) && test_count(freq, positive = TRUE)) {
    freq = as.integer(freq)
  }

  label = if (is.character(freq)) sprintf("\"%s\"", freq) else format(freq)
  steps = grid_steps(order, series, freq)
  n_off = count_missing(steps)
  if (n_off > 0L) {
    error_input(
      paste0(
        "`freq` (%s) does not match order column '%s': %i observation(s) are not a whole number of steps ",
        "after the first observation of their series. Set `freq = NULL` to infer it."
      ),
      label,
      order_col,
      n_off
    )
  }
  later = steps > 0
  gaps = steps[later] - shift(steps)[later]
  n_coarse = length(setdiff(series[later], series[later][gaps == 1]))
  if (n_coarse > 0L) {
    error_input(
      paste0(
        "`freq` (%s) is finer than the spacing of order column '%s': no two consecutive observations are one ",
        "step apart in %i series. Set `freq = NULL` to infer it."
      ),
      label,
      order_col,
      n_coarse
    )
  }
  freq
}

unit_seconds = function(x) {
  if (!test_string(x, min.chars = 1L)) {
    return(NA_real_)
  }
  parts = strsplit1(x, " ")
  n_parts = length(parts)
  n = if (n_parts == 2L) suppressWarnings(as.numeric(parts[1L])) else 1
  unit = sub("s$", "", parts[n_parts])
  if (is.na(n) || n <= 0 || unit %nin% names(unit_secs)) {
    return(NA_real_)
  }
  n * unit_secs[[unit]]
}

# observations per calendar cycle longer than one step, named by cycle
common_periods = function(freq) {
  step = unit_seconds(freq)
  if (is.na(step)) {
    return(numeric())
  }
  cycles = unit_secs[c("min", "hour", "day", "week", "year")]
  periods = cycles / step
  sort(periods[periods > 1])
}

default_period = function(freq) {
  periods = common_periods(freq)
  ladder = c(if ("min" %chin% names(periods)) "hour", "day", "week", "year")
  candidates = unname(periods[names(periods) %chin% ladder])
  if (length(candidates) == 0L) {
    return(1)
  }
  # a cycle of fewer than four observations has no seasonal shape
  long = candidates[candidates >= 4]
  if (length(long) > 0L) long[1L] else candidates[length(candidates)]
}

resolve_period = function(period, freq) {
  if (is.null(period)) {
    return(default_period(freq))
  }
  if (!is.character(period)) {
    return(period)
  }
  step = unit_seconds(freq)
  if (is.na(step)) {
    error_input(
      "A character `period` (%s) requires a calendar `freq`, but `freq` is %s.",
      str_collapse(period, quote = "'"),
      format(freq)
    )
  }
  cycles = map_dbl(period, unit_seconds)
  if (anyNA(cycles)) {
    error_input(
      "Unknown `period` %s. Must be a cycle name such as 'year', 'week' or '2 day'.",
      str_collapse(period[is.na(cycles)], quote = "'")
    )
  }
  cycles / step
}

resolve_measure_period = function(period, task) {
  max(1L, as.integer(round(resolve_period(period, task$freq))))
}

to_tsibble_index = function(order, freq) {
  if (!is.character(freq)) {
    order
  } else if (grepl("week", freq, fixed = TRUE)) {
    tsibble::yearweek(order)
  } else if (grepl("month", freq, fixed = TRUE)) {
    tsibble::yearmonth(order)
  } else if (grepl("quarter", freq, fixed = TRUE)) {
    tsibble::yearquarter(order)
  } else if (grepl("year", freq, fixed = TRUE) && inherits(order, c("Date", "POSIXct", "POSIXlt"))) {
    year(order)
  } else {
    order
  }
}
