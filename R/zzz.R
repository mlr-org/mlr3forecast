#' @import R6
#' @import checkmate
#' @import data.table
#' @import mlr3
#' @import mlr3misc
#' @import paradox
"_PACKAGE"

mlr3forecast_resamplings = new.env()
mlr3forecast_tasks = new.env()
mlr3forecast_feature_types = c(date = "Date")

named_union = function(x, y) {
  z = union(x, y)
  set_names(z, union(names(x), names(y)))
}

register_resampling = function(name, constructor) {
  if (name %in% names(mlr3forecast_resamplings)) stopf("resampling %s registered twice", name)
  mlr3forecast_resamplings[[name]] = constructor
}

register_task = function(name, constructor) {
  if (name %in% names(mlr3forecast_tasks)) stopf("task %s registered twice", name)
  mlr3forecast_tasks[[name]] = constructor
}

register_mlr3 = function() {
  # add task types
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
  # TODO:maybe this can be done more elegantly
  mlr_reflections$task_types = mlr_reflections$task_types[!"fcst"]
  mlr_reflections$task_types = setkeyv(rbind(mlr_reflections$task_types, rowwise_table(
    ~type, ~package, ~task, ~learner, ~prediction, ~prediction_data, ~measure,
    "fcst", "mlr3forecast", "TaskFcst", "LearnerFcst", "PredictionFcst", "PredictionDataFcst", "MeasureFcst"
  ), fill = TRUE), "type")
  mlr_reflections$learner_predict_types$fcst = mlr_reflections$learner_predict_types$regr
  mlr_reflections$task_col_roles$fcst = union(mlr_reflections$task_col_roles$regr, "index")
  mlr_reflections$task_feature_types = named_union(
    mlr_reflections$task_feature_types, mlr3forecast_feature_types
  )

  # add resamplings
  mlr_resamplings = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")
  iwalk(as.list(mlr3forecast_resamplings), function(task, id) mlr_resamplings$add(id, task))

  # add tasks
  mlr_tasks = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
  iwalk(as.list(mlr3forecast_tasks), function(task, id) mlr_tasks$add(id, task))
}

.onLoad = function(libname, pkgname) {
  assign("lg", lgr::get_logger("mlr3"), envir = parent.env(environment()))
  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }
  register_namespace_callback(pkgname, "mlr3", register_mlr3)
}

.onUnload = function(libPaths) { # nolint
  walk(names(mlr3forecast_resamplings), function(nm) mlr_resamplings$remove(nm))
  walk(names(mlr3forecast_tasks), function(nm) mlr_tasks$remove(nm))
  # TODO : remove all reflections
}

leanify_package()
