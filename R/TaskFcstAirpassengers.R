#' @title Air Passengers Regression Task
#'
#' @name mlr_tasks_airpassengers
#' @format [R6::R6Class] inheriting from [mlr3::TaskRegr].
#'
#' @description
#' A toy regression task for the [datasets::AirPassengers] data set.
#' The task represents a monthly time series and is ordered by
#' its only feature `date`.
#'
#' @templateVar id airpassengers
#' @template task
#'
#' @template seealso_task
NULL

load_task_airpassengers = function(id = "airpassengers") {
  dt = tsbox::ts_dt(load_dataset("AirPassengers", package = "datasets"))
  setnames(dt, c("date", "passengers"))
  b = as_data_backend(dt)

  task = TaskFcst$new(
    id = id,
    backend = b,
    target = "passengers",
    index = "date",
    label = "Monthly Airline Passenger Numbers 1949-1960"
  )
  task$col_roles$order = "date"
  b$hash = task$man = "mlr3forecast::mlr_tasks_airpassengers"
  task
}

#' @include zzz.R
register_task("airpassengers", load_task_airpassengers)
