fcst_feature_names = function(task) {
  nms = task$feature_names
  nms[nms != task$col_roles$order]
}

is_task_featureless = function(task) {
  nms = fcst_feature_names(task)
  length(nms) == 0L
}
