#' @title Forecast Task
#'
#' @description
#' This task specializes [mlr3::Task], [mlr3::TaskSupervised] and [mlr3::TaskRegr] for forecasting problems.
#' The target column is assumed to be numeric.
#' The `task_type` is set to `"fcst"`.
#'
#' It is recommended to use [as_task_fcst()] for construction.
#' Predefined tasks are stored in the [dictionary][mlr3misc::Dictionary] [mlr3::mlr_tasks].
#'
#' @template param_id
#' @template param_backend
#' @template param_rows
#' @template param_cols
#'
#' @template seealso_task
#' @export
#' @examplesIf requireNamespace("tsbox", quietly = TRUE)
#' library(data.table)
#' airpassengers = tsbox::ts_dt(AirPassengers)
#' setnames(airpassengers, c("month", "passengers"))
#' task = as_task_fcst(airpassengers, target = "passengers", order = "month", freq = "monthly")
#' task$task_type
#' task$formula()
#' task$truth()
TaskFcst = R6Class(
  "TaskFcst",
  inherit = TaskRegr,
  public = list(
    #' @field freq (`character(1)`)\cr
    #' The frequency of the time series.
    freq = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' The function [as_task_fcst()] provides an alternative way to construct forecast tasks.
    #'
    #' @template param_target
    #' @template param_order
    #' @template param_key
    #' @template param_freq
    #' @template param_label
    #' @template param_extra_args
    initialize = function(
      id,
      backend,
      target,
      order,
      key = NULL,
      freq = NULL,
      label = NA_character_,
      extra_args = list()
    ) {
      assert_frequency(freq)
      super$initialize(id = id, backend = backend, target = target, label = label, extra_args = extra_args)
      self$task_type = "fcst"
      self$freq = freq
      private$.col_roles = insert_named(private$.col_roles, list(key = character()))
      self$extra_args = insert_named(self$extra_args, list(order = order, key = key))
      self$set_col_roles(order, add = "order")
      self$set_col_roles(key, add = "key")
    },

    #' @description
    #' Returns a slice of the data from the [mlr3::DataBackend] as a `data.table`.
    #' Rows default to observations with role `"use"`, and
    #' columns default to features with roles `"target"`, `"order"` or `"feature"`.
    #' If `rows` or `cols` are specified which do not exist in the [mlr3::DataBackend],
    #' an exception is raised.
    #'
    #' Rows and columns are returned in the order specified via the arguments `rows` and `cols`.
    #' If `rows` is `NULL`, rows are returned in the order of `task$row_ids`.
    #' If `cols` is `NULL`, the column order defaults to
    #' `c(task$target_names, task$feature_names)`.
    #' Note that it is recommended to **not** rely on the order of columns, and instead always
    #' address columns with their respective column name.
    #'
    #' @param ordered (`logical(1)`)\cr
    #'   If `TRUE`, data is ordered according to the columns with column role `"order"`.
    #'
    #' @return Depending on the [mlr3::DataBackend], but usually a [data.table::data.table()].
    data = function(rows = NULL, cols = NULL, ordered = FALSE) {
      col_roles = private$.col_roles
      order_cols = col_roles$order
      if (is.null(cols)) {
        cols = c(col_roles$target, col_roles$feature)
        cols = union(order_cols, cols)
      } else {
        assert_subset(cols, self$col_info$id)
      }
      data = super$data(rows, cols, ordered = FALSE)

      if (ordered) {
        if (length(col_roles$key) > 0L) {
          setorderv(data, c(order_cols, col_roles$key))
        } else {
          setorderv(data, order_cols)
        }
      }
      data
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function(...) {
      super$print()
      cat_cli(cli::cli_li("Frequency: {self$freq}"))
    }
  ),

  active = list(
    #' @field properties (`character()`)\cr
    #' Set of task properties.
    #' Possible properties are are stored in [mlr_reflections$task_properties][mlr3::mlr_reflections].
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
    },

    #' @field order ([data.table::data.table()])\cr
    #' If the task has a column with designated role `"order"`, a table with two or more columns:
    #'
    #' * `row_id` (`integer()`), and
    #' * `order` (`Date()` | `POSIXct()` | numeric()).
    #'
    #' Returns `NULL` if there are is no order column.
    order = function(rhs) {
      assert_has_backend(self)
      assert_ro_binding(rhs)
      order_cols = private$.col_roles$order
      # TODO: revisit once finalised, since order should must likely be compulsory
      if (length(order_cols) == 0L) {
        return()
      }
      data = self$backend$data(private$.row_roles$use, c(self$backend$primary_key, order_cols))
      setnames(data, c("row_id", "order"))[]
    },

    #' @field key ([data.table::data.table()])\cr
    #' If the task has a column with designated role `"key"`, a table with two or more columns:
    #'
    #' * `row_id` (`integer()`), and
    #' * key variable(s) (`factor()`).
    #'
    #' If there is only one key column, it will be named as `key`.
    #' Returns `NULL` if there are are no key columns.
    key = function(rhs) {
      assert_has_backend(self)
      assert_ro_binding(rhs)
      key_cols = private$.col_roles$key
      if (length(key_cols) == 0L) {
        return()
      }

      data = self$backend$data(private$.row_roles$use, c(self$backend$primary_key, key_cols))
      # TODO: is there a valid reason for this handling, copyied from mlr3 offset binding?
      if (length(key_cols) == 1L) {
        setnames(data, c("row_id", "key"))[]
      } else {
        setnames(data, c("row_id", key_cols))[]
      }
    }
  )
)
