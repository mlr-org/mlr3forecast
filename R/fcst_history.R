fcst_history_init = function(task) {
  col_roles = task$col_roles
  cols = c(task$target_names, col_roles$key, col_roles$order)
  copy(task$data(cols = cols))
}

fcst_history_combine = function(history, newdata, by) {
  rbindlist(list(history[!newdata, on = by], newdata), use.names = TRUE, fill = TRUE)
}

fcst_history_append = function(history, new_row) {
  rbindlist(list(history, new_row), use.names = TRUE, fill = TRUE)
}
