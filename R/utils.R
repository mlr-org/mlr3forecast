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
  dt = task$data(cols = c(order_cols, key_cols))

  newdata = map_dtr(split(dt, by = key_cols, drop = TRUE), function(dt) {
    dt = dt[get(order_cols) == max(get(order_cols)), c(key_cols, order_cols), with = FALSE]
    max_index = dt[[order_cols]]
    if (inherits(max_index, c("Date", "POSIXct")) && !is.null(task$freq)) {
      index = seq(max_index, length.out = n + 1L, by = task$freq)
    } else {
      index = seq(max_index + 1L, length.out = n + 1L)
    }
    dt = rbindlist(replicate(n, dt, simplify = FALSE))
    set(dt, j = order_cols, value = index[2:(n + 1L)])
  })
  set(newdata, j = task$target_names, value = NA_real_)
  newdata
}

predict_forecast = function(learner, task, h = 12L) {
  learner = assert_learner(as_learner(learner))
  h = assert_count(h, positive = TRUE, coerce = TRUE)
  newdata = generate_newdata(task, h)
  learner$predict_newdata(newdata, task)
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

quantiles_to_level = function(x) {
  x = x[x != 0.5]
  sort(unique(abs(1 - 2 * x) * 100))
}

strsplit1 = function(x, pattern) {
  strsplit(x, pattern, fixed = TRUE)[[1L]]
}
