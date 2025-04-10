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
  max_index = max(task$data(cols = order_cols)[[1L]])

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
  index = index[2:length(index)]

  newdata = data.table(index = index, target = rep(NA_real_, n))
  setnames(newdata, c(order_cols, task$target_names))
}

#' @export
as.ts.TaskFcst = function(x, ...) {
  freq = switch(
    x$freq,
    daily = 365.25,
    weekly = 52L,
    monthly = 12L,
    quarterly = 4L,
    yearly = 1L,
    stopf("Unknown frequency: %s", x$freq)
  )
  stats::ts(x$truth(), freq = freq)
}

fcst_feature_names = function(task) {
  nms = task$feature_names
  nms[nms != task$col_roles$order]
}

is_task_featureless = function(task) {
  nms = fcst_feature_names(task)
  length(nms) == 0L
}

quantiles_to_level = function(x) {
  x = x[x != 0.5]
  sort(unique(abs(1 - 2 * x) * 100))
}
