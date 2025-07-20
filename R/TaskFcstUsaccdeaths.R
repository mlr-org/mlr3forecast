#' @title Accidental Deaths in the US Forecast Task
#'
#' @name mlr_tasks_usaccdeaths
#' @format [R6::R6Class] inheriting from [TaskFcst].
#'
#' @description
#' A forecast task for the popular [datasets::USAccDeaths] data set.
#' The task represents the monthly totals of accidental deaths in the US from 1973 to 1978.
#'
#' @templateVar id usaccdeaths
#' @template task
#'
#' @source
#' `r format_bib("brockwell1991")`
#'
#' @template seealso_task
NULL

load_task_usaccdeaths = function(id = "usaccdeaths") {
  ts = load_dataset("USAccDeaths", "datasets")
  dates = unclass(stats::time(ts))
  dates = as.Date(paste((dates + 0.001) %/% 1L, stats::cycle(ts), 1L, sep = "-"))
  dt = data.table(month = dates, deaths = as.numeric(ts))
  b = as_data_backend(dt)

  task = TaskFcst$new(
    id = id,
    backend = b,
    target = "deaths",
    order = "month",
    freq = "monthly",
    label = "Monthly Accidental Deaths in the US 1973-1978"
  )
  b$hash = task$man = "mlr3forecast::mlr_tasks_usaccdeaths"
  task
}

#' @include zzz.R
register_task("usaccdeaths", load_task_usaccdeaths)
