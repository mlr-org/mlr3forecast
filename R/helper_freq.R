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

# `freq` is the grid step: a calendar string for date indices, or NULL to infer it from the data
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

# days since 1970-01-01 without strptime (Hinnant's days_from_civil)
days_from_civil = function(year, month, day) {
  year = year - (month <= 2L)
  era = year %/% 400L
  yoe = year - era * 400L
  doy = (153L * ((month + 9L) %% 12L) + 2L) %/% 5L + day - 1L
  doe = yoe * 365L + yoe %/% 4L - yoe %/% 100L + doy
  era * 146097L + doe - 719468L
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
  first = days_from_civil(yr, mo, 1L)
  eom = days_from_civil(yr + mo %/% 12L, mo %% 12L + 1L, 1L) - first
  day = pmin(lt$mday, eom)
  if (inherits(origin, "POSIXct")) {
    tz = attr(origin, "tzone") %??% ""
    ISOdatetime(yr, mo, day, lt$hour, lt$min, lt$sec, tz = tz)
  } else {
    structure(as.double(first + day - 1L), class = "Date")
  }
}

# calendar units use their average length, e.g. a month is 365.25 / 12 days
unit_seconds = function(x) {
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

# the seasonal periods a frequency implies, named by cycle: how many observations fit into each calendar cycle
# longer than a single step, shortest first. Empty if the frequency carries no calendar meaning.
common_periods = function(freq) {
  step = if (test_string(freq)) unit_seconds(freq) else NA_real_
  if (is.na(step)) {
    return(numeric())
  }
  cycles = c(minute = 60, hour = 3600, day = 86400, week = 604800, year = 31557600)
  periods = cycles / step
  sort(periods[periods > 1])
}

# the cycle a `ts()` user would reach for: the next natural calendar cycle up from the step, e.g. the
# day for sub-daily data (the hour below a minute) and the week for daily data. Cycles shorter than four
# observations carry no seasonal shape, so they are skipped in favour of the next one up.
default_period = function(freq) {
  periods = common_periods(freq)
  ladder = c(if ("minute" %chin% names(periods)) "hour", "day", "week", "year")
  candidates = unname(periods[names(periods) %chin% ladder])
  if (length(candidates) == 0L) {
    return(1)
  }
  long = candidates[candidates >= 4]
  if (length(long) > 0L) long[1L] else candidates[length(candidates)]
}

# a character period ("year", "week") counts how many steps fit into that cycle
# the measures also score plain regression tasks, whose missing `freq` means no seasonality
resolve_period = function(period, freq) {
  if (is.null(period)) {
    return(default_period(freq))
  }
  if (!is.character(period)) {
    return(period)
  }
  step = if (test_string(freq)) unit_seconds(freq) else NA_real_
  if (is.na(step)) {
    error_input(
      "A character `period` (%s) requires a calendar `freq`, but `freq` is %s.",
      str_collapse(period, quote = "'"),
      if (is.null(freq)) "NULL" else format(freq)
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
