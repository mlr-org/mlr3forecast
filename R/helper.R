#' Generate new data for a forecast task
#'
#' @param task [TaskFcst]\cr
#'   Task.
#' @param n (`integer(1)`)\cr
#'   Number of new data points to generate. Default `1L`.
#' @return A [data.table::data.table()] with `n` new data points.
#' @export
generate_newdata = function(task, n = 1L) {
  task = assert_task(as_task(task), task_type = "fcst")
  n = assert_count(n, positive = TRUE, coerce = TRUE)

  col_roles = task$col_roles
  order_cols = col_roles$order
  key_cols = col_roles$key
  cols = c(order_cols, key_cols)
  dt = task$data(cols = cols)
  setorderv(dt, c(key_cols, order_cols))

  last_rows = if (length(key_cols) > 0L) dt[, .SD[.N], by = key_cols] else dt[.N]

  freq = task$freq %??% infer_freq(dt[[order_cols]])
  newdata = last_rows[rep(seq_len(.N), each = n)]
  if (length(key_cols) > 0L) {
    newdata[, (order_cols) := seq(get(order_cols)[1L], length.out = n + 1L, by = freq)[-1L], by = key_cols]
  } else {
    set(newdata, j = order_cols, value = seq(last_rows[[order_cols]], length.out = n + 1L, by = freq)[-1L])
  }

  set(newdata, j = task$target_names, value = NA_real_)
  newdata
}

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

#' @title Forecast from a Trained Learner
#'
#' @description
#' Generates `h` future rows from the task's skeleton (using [generate_newdata()]), optionally
#' overlays user-supplied `newdata` onto those rows, and predicts with the trained learner via
#' [mlr3::Learner]`$predict_newdata()`. Works with [RecursiveForecaster], [DirectForecaster],
#' and classic `LearnerFcst*` forecasters.
#'
#' @param object ([mlr3::Learner])\cr
#'   A trained forecast learner.
#' @param task ([TaskFcst])\cr
#'   Provides the metadata needed to construct future rows: the order column (to extend the time
#'   index), key columns (for keyed tasks), `freq`, and the column-type schema expected by
#'   `predict_newdata()`. The task's data values are not used. Pass the training task or any other
#'   schema-compatible [TaskFcst].
#' @param h (`integer(1)`)\cr
#'   Forecast horizon — number of future time steps per key.
#' @param newdata ([data.frame()] | `NULL`)\cr
#'   Optional exogenous features for future rows. Must contain the order column (and any key
#'   columns for keyed tasks). Columns other than those are overlaid onto the generated skeleton.
#' @param ... (any)\cr
#'   Ignored.
#' @return [mlr3::Prediction].
#' @export
forecast.Learner = function(object, task, h = 12L, newdata = NULL, ...) {
  assert_learner(object)
  task = assert_task(as_task_fcst(task), task_type = "fcst")
  h = assert_count(h, positive = TRUE, coerce = TRUE)

  generated = generate_newdata(task, h)
  if (!is.null(newdata)) {
    newdata = as.data.table(newdata)
    by_cols = intersect(c(task$col_roles$order, task$col_roles$key), names(newdata))
    if (length(by_cols) == 0L) {
      error_input("`newdata` must contain the order column and any key columns of `task`.")
    }
    overlay_cols = setdiff(names(newdata), by_cols)
    for (col in overlay_cols) {
      generated[newdata, on = by_cols, (col) := mget(paste0("i.", col))]
    }
  }
  object$predict_newdata(generated, task)
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
