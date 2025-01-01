#' @title Forecast Task
#'
#' @description
#' This task specializes [Task] and [TaskSupervised] for forecast problems.
#' The target column is assumed to be numeric.
#' The `task_type` is set to `"fcst"`.
#'
#' It is recommended to use [as_task_fcst()] for construction.
#' Predefined tasks are stored in the [dictionary][mlr3misc::Dictionary] [mlr_tasks].
#'
#' @template param_rows
#' @template param_id
#' @template param_backend
#'
#' @template seealso_task
#' @export
#' @examplesIf requireNamespace("tsbox", quietly = TRUE)
#' airpassengers = tsbox::ts_dt(AirPassengers)
#' data.table::setnames(airpassengers, c("date", "passengers"))
#' task = as_task_fcst(airpassengers, target = "passengers", index = "date")
#' task$task_type
#' task$formula()
#' task$truth()
#' task$data(rows = 1:3)
TaskFcst = R6::R6Class("TaskFcst",
  inherit = TaskRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' The function [as_task_fcst()] provides an alternative way to construct forecast tasks.
    #'
    #' @template param_target
    #' @template param_label
    #' @template param_extra_args
    initialize = function(id, backend, target, label = NA_character_, extra_args = list()) { # nolint
      assert_string(target)

      super$initialize(
        id = id,
        backend = backend,
        target = target,
        label = label,
        extra_args = extra_args
      )
    },

    #' @description
    #' True response for specified `row_ids`. Format depends on the task type.
    #' Defaults to all rows with role "use".
    #' @return `numeric()`.
    truth = function(rows = NULL) {
      super$truth(rows)[[1L]]
    }
  )
)
