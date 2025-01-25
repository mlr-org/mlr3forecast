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

#' @export
as.ts.TaskFcst = function(x, ...) { # nolint
  freq = switch(x$freq,
    daily = 365.25,
    weekly = 52,
    monthly = 12,
    quarterly = 4,
    yearly = 1,
    stopf("Unknown frequency: %s", x$freq)
  )
  stats::ts(x$truth(), freq = freq)
}

#' Generate new data for a forecast task
#'
#' @param task [TaskFcst]
#' @param n (`integer(1)`) number of new data points to generate. Default `1L`.
#' @return A `data.frame()` with `n` new data points.
#' @export
generate_newdata = function(task, n = 1L) {
  assert_count(n)
  order_cols = task$col_roles$order
  max_index = max(task$data(cols = order_cols)[[1L]])

  unit = switch(task$freq,
    daily = "day",
    weekly = "week",
    monthly = "month",
    quarterly = "quarter",
    yearly = "quarterly"
  )
  unit = sprintf("1 %s", unit)
  index = seq(max_index, length.out = n + 1L, by = unit)
  index = index[2:length(index)]

  newdata = data.frame(index = index, target = rep(NA_real_, n), check.names = FALSE)
  set_names(newdata, c(order_cols, task$target_names))
}
