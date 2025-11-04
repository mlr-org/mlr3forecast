#' @title Daily electricity demand for Victoria, Australia Forecast Task
#'
#' @name mlr_tasks_electricity
#' @format [R6::R6Class] inheriting from [TaskFcst].
#'
#' @description
#' A forecast task for the [tsibbledata::vic_elec] data set.
#' The task represents a daily time series and is ordered by `date`.
#'
#' @templateVar id electricity
#' @template task
#'
#' @template seealso_task
NULL

load_task_electricty = function(id = "electricity") {
  require_namespaces("tsibbledata")
  dt = as.data.table(load_dataset("vic_elec", "tsibbledata"))
  setnames(dt, tolower)
  demand = temperature = holiday = NULL
  dt = dt[, list(demand = sum(demand), temperature = max(temperature), holiday = any(holiday)), by = "date"]
  b = as_data_backend(dt)

  task = TaskFcst$new(
    id = id,
    backend = b,
    target = "demand",
    order = "date",
    freq = "daily",
    label = "Daily electricity demand for Victoria, Australia"
  )
  b$hash = task$man = "mlr3forecast::mlr_tasks_electricity"
  task
}

#' @include zzz.R
register_task("electricity", load_task_electricty)
