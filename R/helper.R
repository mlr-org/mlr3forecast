infer_freq = function(order) {
  if (!inherits(order, c("Date", "POSIXct", "POSIXlt")) || length(order) < 2L) {
    return(1L)
  }
  secs = max(round(as.numeric(stats::median(diff(as.POSIXct(order))), units = "secs")), 1)
  if (secs == 604800) {
    "week"
  } else if (secs >= 2419200) {
    # >= 28 days: calendar-anchored data (constant day-of-month) gets calendar units,
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
      # neither calendar-anchored nor whole days (e.g. month-end data): magnitude guess
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
  k = year(origin) * 12L + month(origin) - 1L + m * seq_len(n)
  yr = k %/% 12L
  mo = k %% 12L + 1L
  eom = mday(as.Date(ISOdate(yr + mo %/% 12L, mo %% 12L + 1L, 1L)) - 1L)
  at_eom = month(as.IDate(origin) + 1L) != month(origin)
  day = if (at_eom) eom else pmin(mday(origin), eom)
  if (inherits(origin, "POSIXct")) {
    tz = attr(origin, "tzone") %??% ""
    ISOdatetime(yr, mo, day, hour(origin), minute(origin), second(origin), tz = tz)
  } else {
    as.Date(ISOdate(yr, mo, day))
  }
}

#' @export
as.ts.TaskFcst = function(x, ..., freq = NULL) {
  freq = freq_to_period(freq %??% x$freq)
  stats::ts(x$truth(), freq = freq)
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

quantiles_to_levels = function(x) {
  x = x[x != 0.5]
  sort(unique(round(abs(1 - 2 * x) * 100, 6)))
}

strsplit1 = function(x, pattern) {
  strsplit(x, pattern, fixed = TRUE)[[1L]]
}

score_grouped = function(score_fn, prediction, task, train_set = NULL, ...) {
  key_cols = task$col_roles$key
  key_data = task$data(rows = prediction$row_ids, cols = key_cols)
  groups = split(prediction$row_ids, key_data, drop = TRUE)

  train_groups = NULL
  if (!is.null(train_set)) {
    train_key_data = task$data(rows = train_set, cols = key_cols)
    train_groups = split(train_set, train_key_data, drop = TRUE)
    missing = setdiff(names(groups), names(train_groups))
    if (length(missing) > 0L) {
      error_input("Key group(s) %s have no observations in the training set.", str_collapse(missing, quote = "'"))
    }
  }

  scores = map_dbl(names(groups), function(nm) {
    pred = prediction$clone()$filter(groups[[nm]])
    score_fn(pred, task, train_set = train_groups[[nm]], ...)
  })
  mean(scores)
}

fcst_drop_incomplete = function(dt, feat_cols, key_cols) {
  kept = stats::na.omit(dt, cols = feat_cols)
  if (nrow(kept) == 0L) {
    error_input("The series is too short for the requested lags or window sizes.")
  }
  if (length(key_cols) > 0L && nrow(kept) < nrow(dt)) {
    dropped = unique(dt[, key_cols, with = FALSE])[!kept, on = key_cols]
    if (nrow(dropped) > 0L) {
      labels = do.call(paste, c(dropped, list(sep = ":")))
      warning_input(
        "Dropped %i series too short for the requested lags/windows: %s.",
        nrow(dropped),
        str_collapse(labels, quote = "'")
      )
    }
  }
  kept
}
