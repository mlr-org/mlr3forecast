#' @title Annual Canadian Lynx Trappings Forecast Task
#'
#' @name mlr_tasks_lynx
#' @format [R6::R6Class] inheriting from [TaskFcst].
#'
#' @description
#' A forecast task for the popular [datasets::lynx] data set.
#' The task represents the annual numbers of lynx trappings in Canada from 1821 to 1934.
#'
#' @templateVar id lynx
#' @template task
#'
#' @source
#' `r format_bib("brockwell1991forecasting")`
#'
#' @template seealso_task
NULL

load_task_lynx = function(id = "lynx") {
  ts = load_dataset("lynx", "datasets")
  dt = data.table(year = as.integer(stats::time(ts)), count = as.numeric(ts))
  b = as_data_backend(dt)

  task = TaskFcst$new(
    id = id,
    backend = b,
    target = "count",
    order = "year",
    freq = "yearly",
    label = "Annual Canadian Lynx Trappings 1821-1934"
  )
  b$hash = task$man = "mlr3forecast::mlr_tasks_lynx"
  task
}

#' @include zzz.R
register_task("lynx", load_task_lynx)
