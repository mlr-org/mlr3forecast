#' @title Air Passengers Forecast Task
#'
#' @name mlr_tasks_airpassengers
#' @format [R6::R6Class] inheriting from [TaskFcst].
#'
#' @description
#' A toy forecast task for the [datasets::AirPassengers] data set.
#' The task represents a monthly time series and is ordered by its only feature `date`.
#'
#' @templateVar id airpassengers
#' @template task
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
