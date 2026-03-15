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
  order_col = col_roles$order
  key_cols = col_roles$key
  cols = c(order_col, key_cols)
  dt = task$data(cols = cols)

  last_rows = if (length(key_cols) > 0L) dt[, .SD[.N], by = key_cols] else last_rows = dt[.N]

  is_temporal = inherits(last_rows[[order_col]], c("Date", "POSIXct")) && !is.null(task$freq)
  next_index = if (is_temporal) {
    function(max_index) seq(max_index, length.out = n + 1L, by = task$freq)[-1L]
  } else {
    function(max_index) seq.int(max_index + 1L, length.out = n)
  }

  newdata = last_rows[rep(seq_len(.N), each = n)]
  if (length(key_cols) > 0L) {
    newdata[, (order_col) := next_index(.SD[[1L]][1L]), by = key_cols, .SDcols = order_col]
  } else {
    set(newdata, j = order_col, value = next_index(last_rows[[order_col]]))
  }

  set(newdata, j = task$target_names, value = NA_real_)
  newdata
}

#' @export
as.ts.TaskFcst = function(x, ..., freq = NULL) {
  freq = freq %??% x$freq %??% 1L
  if (is.character(freq)) {
    # fmt: skip
    freq = switch(
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
  stats::ts(x$truth(), freq = freq)
}

predict_forecast = function(learner, task, h = 12L) {
  learner = assert_learner(as_learner(learner))
  h = assert_count(h, positive = TRUE, coerce = TRUE)
  newdata = generate_newdata(task, h)
  learner$predict_newdata(newdata, task)
}

quantiles_to_level = function(x) {
  x = x[x != 0.5]
  sort(unique(abs(1 - 2 * x) * 100))
}

strsplit1 = function(x, pattern) {
  strsplit(x, pattern, fixed = TRUE)[[1L]]
}

score_grouped = function(score_fn, prediction, task, train_set = NULL, ...) {
  key_cols = task$col_roles$key
  key_data = task$data(rows = prediction$row_ids, cols = key_cols)
  groups = split(prediction$row_ids, key_data)

  if (!is.null(train_set)) {
    train_key_data = task$data(rows = train_set, cols = key_cols)
    train_groups = split(train_set, train_key_data)
  }

  scores = map_dbl(names(groups), function(nm) {
    pred = prediction$clone()$filter(groups[[nm]])
    train_set = if (!is.null(train_set)) train_groups[[nm]]
    score_fn(pred, task, train_set = train_set, ...)
  })
  mean(scores)
}
