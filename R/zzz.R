#' @import R6
#' @import checkmate
#' @import data.table
#' @import mlr3
#' @import mlr3misc
#' @import paradox
"_PACKAGE"

mlr3forecast_resamplings = new.env()

register_resampling = function(name, constructor) {
  if (name %in% names(mlr3forecast_resamplings)) stopf("resampling %s registered twice", name)
  mlr3forecast_resamplings[[name]] = constructor
}

register_mlr3 = function() {
  # add resamplings
  mlr_resamplings = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")
  iwalk(as.list(mlr3forecast_resamplings), function(task, id) mlr_resamplings$add(id, task))
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
}

leanify_package()
