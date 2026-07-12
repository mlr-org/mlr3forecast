quantiles_to_levels = function(x) {
  x = x[x != 0.5]
  sort(unique(round(abs(1 - 2 * x) * 100, 6)))
}

strsplit1 = function(x, pattern) {
  strsplit(x, pattern, fixed = TRUE)[[1L]]
}

chrono_order = function(prediction, task) {
  order_col = task$col_roles$order
  if (length(order_col) == 0L) {
    return(seq_along(prediction$row_ids))
  }
  order_vals = task$data(rows = prediction$row_ids, cols = order_col)[[1L]]
  order(order_vals)
}

ordered_features = function(task, learner) {
  cols = names(learner$state$data_prototype) %??% learner$state$feature_names
  task$data(cols = intersect(cols, task$feature_names))
}
