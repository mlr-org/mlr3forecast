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

# a numeric freq is the seasonal period, not the grid step, so only calendar freqs step the grid
resolve_step = function(freq, order) {
  if (is.character(freq)) freq else infer_freq(sort(unique(order)))
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

#' @export
as.ts.TaskFcst = function(x, ..., freq = NULL) {
  if (length(x$col_roles$key) > 0L) {
    error_input("Cannot coerce a multi-series (keyed) task to a single ts object.")
  }
  freq = freq_to_period(freq %??% x$freq)
  y = x$data(cols = x$target_names, ordered = TRUE)[[1L]]
  stats::ts(y, freq = freq)
}

freq_to_period = function(freq) {
  if (is.null(freq)) {
    return(1L)
  }
  if (!is.character(freq)) {
    return(freq)
  }
  periods = c(
    secs = 60,
    mins = 1440,
    hours = 24,
    days = 365.25,
    DSTdays = 365.25,
    weeks = 52.18,
    months = 12,
    quarters = 4,
    years = 1
  )
  parts = strsplit1(freq, " ")
  n_parts = length(parts)
  n = if (n_parts == 2L) suppressWarnings(as.numeric(parts[1L])) else 1
  ii = pmatch(parts[n_parts], names(periods))
  if (is.na(ii) || is.na(n) || n <= 0) {
    return(1L)
  }
  periods[[ii]] / n
}

resolve_measure_period = function(period, freq) {
  if (!is.null(period)) {
    return(period)
  }
  max(1L, as.integer(round(freq_to_period(freq))))
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
