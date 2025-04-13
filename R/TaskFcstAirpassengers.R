#' @title Air Passengers Forecast Task
#'
#' @name mlr_tasks_airpassengers
#' @format [R6::R6Class] inheriting from [TaskFcst].
#'
#' @description
#' A forecast task for the popular [datasets::AirPassengers] data set.
#' The task represents the monthly totals of international airline passengers from 1949 to 1960.
#'
#' @templateVar id airpassengers
#' @template task
#'
#' @source
#' `r format_bib("box1976")`
#'
#' @template seealso_task
NULL

load_task_airpassengers = function(id = "airpassengers") {
  ts = load_dataset("AirPassengers", "datasets")
  dates = unclass(stats::time(ts))
  dates = as.Date(paste((dates + 0.001) %/% 1L, stats::cycle(ts), 1L, sep = "-"))
  dt = data.table(month = dates, passengers = as.numeric(ts))
  b = as_data_backend(dt)

  task = TaskFcst$new(
    id = id,
    backend = b,
    target = "passengers",
    order = "month",
    freq = "monthly",
    label = "Monthly Airline Passenger Numbers 1949-1960"
  )
  b$hash = task$man = "mlr3forecast::mlr_tasks_airpassengers"
  task$col_roles$feature = setdiff(task$col_roles$feature, "month")
  task
}

#' @include zzz.R
register_task("airpassengers", load_task_airpassengers)
