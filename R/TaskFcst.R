#' @title Forecast Task
#'
#' @description
#' This task specializes [Task], [TaskSupervised] and [TaskRegr] for forecasting problems.
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
#' airpassengers = tsbox::ts_dt(load_dataset("AirPassengers", "datasets"))
#' setnames(airpassengers, c("date", "passengers"))
#' task = as_task_fcst(airpassengers, target = "passengers", order = "date")
#' task$task_type
#' task$formula()
#' task$truth()
TaskFcst = R6Class("TaskFcst",
  inherit = TaskRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' The function [as_task_fcst()] provides an alternative way to construct forecast tasks.
    #'
    #' @template param_target
    #' @template param_order
    #' @template param_key
    #' @template param_label
    #' @template param_extra_args
    initialize = function(id, backend, target, order, key = NULL, label = NA_character_, extra_args = list()) {
      super$initialize(
        id = id,
        backend = backend,
        target = target,
        label = label,
        extra_args = extra_args
      )
      self$task_type = "fcst"
      private$.col_roles = insert_named(private$.col_roles, list(key = character()))
      self$extra_args = insert_named(self$extra_args, list(order = order, key = key))
      self$set_col_roles(order, add = "order")
      self$set_col_roles(key, add = "key")
    }
  ),

  active = list(
    #' @field properties (`character()`)\cr
    #' Set of task properties.
    #' Possible properties are are stored in [mlr_reflections$task_properties][mlr_reflections].
    #' The following properties are currently standardized and understood by tasks in \CRANpkg{mlr3}:
    #'
    #' * `"strata"`: The task is resampled using one or more stratification variables (role `"stratum"`).
    #' * `"groups"`: The task comes with grouping/blocking information (role `"group"`).
    #' * `"weights"`: The task comes with observation weights (role `"weight"`).
    #' * `"ordered"`: The task has columns which define the row order (role `"order"`).
    #' * `"keys"`: The task has columns which define the time series `"key"`).
    #'
    #' Note that above listed properties are calculated from the `$col_roles` and may not be set explicitly.
    properties = function(rhs) {
      if (missing(rhs)) {
        c(super$properties, if (length(private$.col_roles$key)) "keys" else NULL)
      } else {
        super$properties = rhs
      }
    }
  )
)
