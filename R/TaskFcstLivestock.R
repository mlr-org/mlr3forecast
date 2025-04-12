#' @title Australian Livestock Slaughter Forecast Task
#'
#' @name mlr_tasks_livestock
#' @format [R6::R6Class] inheriting from [TaskFcst].
#'
#' @description
#' A forecast task for the [tsibbledata::aus_livestock] data set.
#' The task represents a monthly time series and is ordered by `month`.
#'
#' @templateVar id livestock
#' @template task
#'
#' @template seealso_task
NULL

load_task_livestock = function(id = "livestock") {
  require_namespaces(c("tsibbledata", "tsibble"))
  dt = as.data.table(load_dataset("aus_livestock", "tsibbledata"))
  setnames(dt, tolower)
  dt[, month := as.Date(month)]
  b = as_data_backend(dt)

  task = TaskFcst$new(
    id = id,
    backend = b,
    target = "count",
    order = "month",
    key = c("animal", "state"),
    freq = "monthly",
    label = "Australian livestock slaughter"
  )
  b$hash = task$man = "mlr3forecast::mlr_tasks_livestock"
  task$col_roles$feature = setdiff(task$col_roles$feature, "month")
  task
}

#' @include zzz.R
register_task("livestock", load_task_livestock)
