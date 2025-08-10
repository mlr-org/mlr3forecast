#' Generate new data for a forecast task
#'
#' @param task [TaskFcst]
#' @param n (`integer(1)`) number of new data points to generate. Default `1L`.
#' @return A [data.table::data.table()] with `n` new data points.
#' @export
generate_newdata = function(task, n = 1L) {
  task = assert_task(as_task(task), task_type = "fcst")
  n = assert_count(n, positive = TRUE, coerce = TRUE)

  order_cols = task$col_roles$order
  key_cols = task$col_roles$key
  dt = task$data(cols = c(order_cols, key_cols))

  newdata = map_dtr(split(dt, by = key_cols, drop = TRUE), function(dt) {
    dt = dt[get(order_cols) == max(get(order_cols)), c(key_cols, order_cols), with = FALSE]
    max_index = dt[[order_cols]]
    if (inherits(max_index, c("Date", "POSIXct")) && !is.null(task$freq)) {
      unit = switch(
        task$freq,
        secondly = "second",
        minutely = "minute",
        hourly = "hour",
        daily = "day",
        weekly = "week",
        monthly = "month",
        quarterly = "quarter",
        yearly = "yearly"
      )
      unit = sprintf("1 %s", unit)
      index = seq(max_index, length.out = n + 1L, by = unit)
    } else {
      index = seq(max_index + 1L, length.out = n + 1L)
    }
    dt = rbindlist(replicate(n, dt, simplify = FALSE))
    dt[, (order_cols) := index[2:(n + 1L)]]
  })
  newdata[, (task$target_names) := NA_real_][]
}

predict_forecast = function(learner, task, h = 12L) {
  learner = assert_learner(as_learner(learner))
  h = assert_count(h, positive = TRUE, coerce = TRUE)
  newdata = generate_newdata(task, h)
  learner$predict_newdata(newdata, task)
}

#' @export
as.ts.TaskFcst = function(x, ..., freq = NULL) {
  # TODO: come back to this once decided if a task requires a frequency or falls back to 1L
  freq = freq %??% x$freq %??% 1L
  if (is.character(freq)) {
    freq = switch(
      freq,
      secondly = 60L,
      minutely = 1440L,
      hourly = 24L,
      daily = 365.25,
      weekly = 52.18,
      monthly = 12L,
      quarterly = 4L,
      yearly = 1L
    )
  }
  stats::ts(x$truth(), freq = freq)
}

quantiles_to_level = function(x) {
  x = x[x != 0.5]
  sort(unique(abs(1 - 2 * x) * 100))
}
