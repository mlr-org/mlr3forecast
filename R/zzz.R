#' @import checkmate
#' @import data.table
#' @import mlr3
#' @import mlr3misc
#' @import mlr3pipelines
#' @import paradox
#' @importFrom R6 R6Class
#' @importFrom ggplot2 autoplot
#' @importFrom stats as.ts
#' @importFrom utils tail
"_PACKAGE"

mlr3forecast_resamplings = new.env(parent = emptyenv())
mlr3forecast_tasks = new.env(parent = emptyenv())
mlr3forecast_learners = new.env(parent = emptyenv())
mlr3forecast_measures = new.env(parent = emptyenv())
mlr3forecast_col_roles = "key"
mlr3forecast_learner_properties = "exogenous"
mlr3forecast_task_print_col_roles = c("Key by" = "key")
mlr3forecast_task_properties = c("univariate", "multivariate", "ordered", "keys")
mlr3forecast_pipeops = new.env(parent = emptyenv())
mlr3forecast_pipeop_tags = "fcst"

named_union = function(x, y) set_names(union(x, y), union(names(x), names(y)))

register_item = function(env, type) {
  function(name, constructor) {
    if (name %in% names(env)) {
      stopf("%s %s registered twice.", type, name)
    }
    env[[name]] = constructor
  }
}

# metainf must be manually added in the register_mlr3pipelines function
# Because the value is substituted, we cannot pass it through this function
register_po = function(name, constructor) {
  if (name %in% names(mlr3forecast_pipeops)) {
    stopf("pipeop %s registered twice.", name)
  }
  mlr3forecast_pipeops[[name]] = list(constructor = constructor)
}

register_resampling = register_item(mlr3forecast_resamplings, "resampling")
register_task = register_item(mlr3forecast_tasks, "task")
register_learner = register_item(mlr3forecast_learners, "learner")
register_measure = register_item(mlr3forecast_measures, "measure")

register_mlr3 = function() {
  # add reflections
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
  mlr_reflections$task_types = mlr_reflections$task_types[!"fcst"]
  # fmt: skip
  mlr_reflections$task_types = setkeyv(rbind(mlr_reflections$task_types, rowwise_table(
    ~type, ~package, ~task, ~learner, ~prediction, ~prediction_data, ~measure,
    "fcst", "mlr3forecast", "TaskFcst", "LearnerRegr", "PredictionRegr", "PredictionDataRegr", "MeasureRegr"
  ), fill = TRUE), "type")
  mlr_reflections$learner_predict_types$fcst = mlr_reflections$learner_predict_types$regr
  mlr_reflections$learner_properties$fcst = union(
    mlr_reflections$learner_properties$regr,
    mlr3forecast_learner_properties
  )
  # remove regr roles that should have no effect or expect setting
  mlr_reflections$task_col_roles$fcst = union(mlr_reflections$task_col_roles$regr, mlr3forecast_col_roles)
  mlr_reflections$task_properties$fcst = mlr3forecast_task_properties
  mlr_reflections$measure_properties$fcst = mlr_reflections$measure_properties$regr
  mlr_reflections$task_print_col_roles$after = named_union(
    mlr_reflections$task_print_col_roles$after,
    mlr3forecast_task_print_col_roles
  )

  # add resamplings
  mlr_resamplings = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")
  iwalk(as.list(mlr3forecast_resamplings), function(resampling, id) mlr_resamplings$add(id, resampling))

  # add tasks
  mlr_tasks = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
  iwalk(as.list(mlr3forecast_tasks), function(task, id) mlr_tasks$add(id, task))

  # add learners
  mlr_learners = utils::getFromNamespace("mlr_learners", ns = "mlr3")
  iwalk(as.list(mlr3forecast_learners), function(learner, id) mlr_learners$add(id, learner))

  # add measures
  mlr_measures = utils::getFromNamespace("mlr_measures", ns = "mlr3")
  iwalk(as.list(mlr3forecast_measures), function(measure, id) mlr_measures$add(id, measure))
}

register_mlr3pipelines = function() {
  mlr_reflections = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
  mlr_pipeops = utils::getFromNamespace("mlr_pipeops", ns = "mlr3pipelines")
  iwalk(as.list(mlr3forecast_pipeops), function(value, name) mlr_pipeops$add(name, value$constructor, value$metainf))
  mlr_reflections$pipeops$valid_tags = union(mlr_reflections$pipeops$valid_tags, mlr3forecast_pipeop_tags)
}

.onLoad = function(libname, pkgname) {
  backports::import(pkgname)

  assign("lg", lgr::get_logger("mlr3"), envir = parent.env(environment()))
  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }

  register_namespace_callback(pkgname, "mlr3", register_mlr3)
  register_namespace_callback(pkgname, "mlr3pipelines", register_mlr3pipelines)
}

.onUnload = function(libPaths) {
  walk(names(mlr3forecast_resamplings), function(nm) mlr_resamplings$remove(nm))
  walk(names(mlr3forecast_tasks), function(nm) mlr_tasks$remove(nm))
  walk(names(mlr3forecast_learners), function(nm) mlr_learners$remove(nm))
  walk(names(mlr3forecast_measures), function(nm) mlr_measures$remove(nm))
  walk(names(mlr3forecast_pipeops), function(nm) mlr_pipeops$remove(nm))

  mlr_reflections$task_types = mlr_reflections$task_types[!"fcst"]
  reflections = c("learner_predict_types", "task_col_roles", "task_properties")
  walk(reflections, function(x) mlr_reflections[[x]] = remove_named(mlr_reflections[[x]], "fcst"))
  mlr_reflections$pipeops$valid_tags = setdiff(mlr_reflections$pipeops$valid_tags, mlr3forecast_pipeop_tags)
}

leanify_package()
