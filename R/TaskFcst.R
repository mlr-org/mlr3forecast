#' @title Forecast Task
#'
#' @description
#' This task specializes [Task] and [TaskSupervised] for regression problems.
#' The target column is assumed to be numeric.
#' The `task_type` is set to `"regr"`.
#'
#' It is recommended to use [as_task_regr()] for construction.
#' Predefined tasks are stored in the [dictionary][mlr3misc::Dictionary] [mlr_tasks].
#'
#' @template param_rows
#' @template param_id
#' @template param_backend
#'
#' @template seealso_task
#' @export
#' @examples
#' task = as_task_regr(palmerpenguins::penguins, target = "bill_length_mm")
#' task$task_type
#' task$formula()
#' task$truth()
#' task$data(rows = 1:3, cols = task$feature_names[1:2])
TaskFcst = R6Class("TaskFcst",
  inherit = TaskRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' The function [as_task_regr()] provides an alternative way to construct regression tasks.
    #'
    #' @template param_target
    #' @template param_label
    #' @template param_extra_args
    initialize = function(id, backend, target, label = NA_character_, extra_args = list()) {
      super$initialize(
        id = id,
        backend = backend,
        target = target,
        label = label,
        extra_args = extra_args
      )
      self$task_type = "fcst"
      private$.col_roles = insert_named(private$.col_roles, list(key = character()))
    }
  ),

  active = list(
    properties = function(rhs) {
      if (missing(rhs)) {
        c(super$properties, if (length(private$.col_roles$key)) "keys" else NULL)
      } else {
        super$properties = rhs
      }
    }
  )
)

#' @rdname task_check_col_roles
#' @export
task_check_col_roles.TaskFcst = function(task, new_roles, ...) {
  # TODO: check for key role and order, since not in mlr3
  NextMethod()
}
