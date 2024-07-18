#' @import R6
#' @import checkmate
#' @import data.table
#' @import mlr3
#' @import mlr3misc
#' @import mlr3misc
#' @import paradox
"_PACKAGE"

.onLoad = function(libname, pkgname) {
  assign("lg", lgr::get_logger("mlr3"), envir = parent.env(environment()))
  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }
}

leanify_package()
