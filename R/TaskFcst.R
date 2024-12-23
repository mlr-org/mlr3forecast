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
  inherit = TaskSupervised,
  public = list(
    #' @field index (`character(1)`)\cr
    #' Column name of the index variable.
    index = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' The function [as_task_fcst()] provides an alternative way to construct forecast tasks.
    #'
    #' @param index (`character(1)`)\cr
    #'   Column name of the index variable.
    #' @template param_target
    #' @template param_label
    #' @template param_extra_args
    initialize = function(id, backend, target, index, label = NA_character_, extra_args = list()) { # nolint
      assert_string(target)
      assert_string(index)

      super$initialize(
        id = id,
        task_type = "regr", # has to be regr for now otherwise learner won't work
        backend = backend,
        target = target,
        label = label,
        extra_args = extra_args
      )
      self$index = index
      private$.col_roles$feature = setdiff(private$.col_roles$feature, index)
    },

    #' @description
    #' True response for specified `row_ids`. Format depends on the task type.
    #' Defaults to all rows with role "use".
    #' @returns `numeric()`.
    truth = function(rows = NULL) {
      super$truth(rows)[[1L]]
    }
  )
)
