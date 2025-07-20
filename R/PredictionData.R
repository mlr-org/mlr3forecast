new_prediction_data = function(li, task_type) {
  li = discard(li, is.null)
  class(li) = c(fget(mlr_reflections$task_types, task_type, "prediction_data", "type"), "PredictionData")
  li
}
