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
  freq = switch(x$frequency,
    daily = 365.25,
    weekly = 52,
    monthly = 12,
    quarterly = 4,
    yearly = 1,
    stopf("Unknown frequency: %s", x$frequency)
  )
  stats::ts(x$truth(), freq = freq)
}
