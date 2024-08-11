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
#' task = as_task_fcst(airpassengers, target = "value", index = "time", freq = "month")
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

    #' @field freq (`character(1)`)\cr
    #' Frequency of the time series.
    freq = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' The function [as_task_fcst()] provides an alternative way to construct forecast tasks.
    #'
    #' @param index (`character(1)`)\cr
    #'   Column name of the index variable.
    #' @param freq (`character(1)`)\cr
    #'   Frequency of the time series.
    #' @template param_target
    #' @template param_label
    #' @template param_extra_args
    initialize = function(id, backend, target, index, freq, label = NA_character_, extra_args = list()) { # nolint
      assert_string(target)
      assert_string(index)
      assert_string(freq)

      super$initialize(
        id = id,
        task_type = "fcst",
        backend = backend,
        target = target,
        label = label,
        extra_args = extra_args
      )
      self$properties = union(
        self$properties, if (length(self$target_names) == 1L) "univariate" else "multivariate"
      )
      self$index = index
      self$freq = freq

      # TODO: seems very hacky
      private$.col_roles$feature = setdiff(private$.col_roles$feature, index)
      # TODO: should it every be null?
      self$col_roles$index = index %??% "time"

      type = self$col_info[id == target]$type
      if (type %nin% c("integer", "numeric")) {
        stopf("Target column '%s' must be numeric", target)
      }
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function(...) {
      super$print(...)
      catn(str_indent("* Index:", self$index))
      catn(str_indent("* Frequency:", self$freq))
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
