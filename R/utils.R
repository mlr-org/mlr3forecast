#' Generate new data for a forecast task
#'
#' @param task [TaskFcst]
#' @param n (`integer(1)`) number of new data points to generate. Default `1L`.
#' @return A [data.table::data.table()] with `n` new data points.
#' @export
generate_newdata = function(task, n = 1L) {
  task = assert_task(as_task(task), task_type = "fcst")
  n = assert_count(n, positive = TRUE, coerce = TRUE)

  if ("keys" %chin% task$properties) {
    stopf("`generate_newdata()` does not yet support tasks with keys.")
  }

  order_cols = task$col_roles$order
  max_index = max(task$data(cols = order_cols)[[1L]])

  if (inherits(max_index, c("Date", "POSIXct"))) {
    unit = switch(
      task$freq,
      daily = "day",
      weekly = "week",
      monthly = "month",
      quarterly = "quarter",
      yearly = "quarterly"
    )
    unit = sprintf("1 %s", unit)
    index = seq(max_index, length.out = n + 1L, by = unit)
  } else {
    index = seq(max_index + 1L, length.out = n + 1L)
  }
  index = index[2:length(index)]

  newdata = data.table(index = index, target = rep(NA_real_, n))
  setnames(newdata, c(order_cols, task$target_names))
  newdata
}

#' @export
as.ts.TaskFcst = function(x, ...) {
  freq = switch(
    x$freq,
    daily = 365.25,
    weekly = 52.18,
    monthly = 12L,
    quarterly = 4L,
    yearly = 1L,
    stopf("Unknown frequency: %s", x$freq)
  )
  stats::ts(x$truth(), freq = freq)
}

quantiles_to_level = function(x) {
  x = x[x != 0.5]
  sort(unique(abs(1 - 2 * x) * 100))
}

assert_frequency = function(x) {
  assert(
    check_null(x),
    check_choice(x, c("daily", "weekly", "monthly", "quarterly", "yearly")),
    check_number(x, lower = 0, finite = TRUE)
  )
}
