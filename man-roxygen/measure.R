#' @section Dictionary:
#' This [mlr3::Measure] can be instantiated via the [dictionary][mlr3misc::Dictionary] [mlr3::mlr_measures] or with the associated sugar function [mlr3::msr()]:
#' ```
#' mlr_measures$get("<%= id %>")
#' msr("<%= id %>")
#' ```
#'
#' @section Task type:
#' Forecast measures are registered with `task_type = "regr"` so they compose with the standard regression
#' measures (e.g. [mlr3::mlr_measures_regr.rmse]) on the [PredictionFcst] that forecast learners produce.
#' List them via the key prefix, not the task type, as the latter returns nothing:
#' ```
#' as.data.table(mlr_measures)[grepl("^fcst", key)]
#' ```
#'
#' @section Meta Information:
#' `r mlr3misc::rd_info(mlr3::msr("<%= id %>"))`
#'
#' @section Parameters:
#' `r mlr3misc::rd_info(mlr3::msr("<%= id %>")$param_set)`
