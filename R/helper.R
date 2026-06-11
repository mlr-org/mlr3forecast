infer_freq = function(order) {
  if (!inherits(order, c("Date", "POSIXct", "POSIXlt")) || length(order) < 2L) {
    return(1L)
  }
  p = max(round(as.numeric(stats::median(diff(as.POSIXct(order))), units = "secs")), 1)
  if (p == 604800) {
    "week"
  } else if (p >= 2419200) {
    # >= 28 days: calendar-anchored data (constant day-of-month) gets calendar units,
    # fixed-interval data gets exact day multiples
    m = round(p / 2629800)
    if (uniqueN(mday(order)) == 1L) {
      if (m == 3L) {
        "quarter"
      } else if (m == 12L) {
        "year"
      } else {
        sprintf("%g month", m)
      }
    } else if (p %% 86400 == 0) {
      sprintf("%g day", p / 86400)
    } else {
      # neither calendar-anchored nor whole days (e.g. month-end data): magnitude guess
      if (p <= 2678400) {
        "month"
      } else if (p <= 7948800) {
        "quarter"
      } else {
        "year"
      }
    }
  } else if (p %% 86400 == 0) {
    sprintf("%g day", p / 86400)
  } else if (p %% 3600 == 0) {
    sprintf("%g hour", p / 3600)
  } else if (p %% 60 == 0) {
    sprintf("%g min", p / 60)
  } else {
    sprintf("%g sec", p)
  }
}

#' @export
as.ts.TaskFcst = function(x, ..., freq = NULL) {
  freq = freq_to_int(freq %??% x$freq)
  stats::ts(x$truth(), freq = freq)
}

freq_to_int = function(freq) {
  if (is.null(freq)) {
    return(1L)
  }
  if (!is.character(freq)) {
    return(freq)
  }
  # fmt: skip
  switch(
    freq,
    `1 sec` = , sec = , secs = 60L,
    `1 min` = , min = , mins = 1440L,
    `1 hour` = , hour = , hours = 24L,
    `1 day` = , day = , days = 365.25,
    `1 week` = , week = , weeks = 52.18,
    `1 month` = , month = , months = 12L,
    `3 months` = , `1 quarter` = , quarter = , quarters = 4L,
    `1 year` = , year = , years = 1L,
    1L
  )
}

quantiles_to_level = function(x) {
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
