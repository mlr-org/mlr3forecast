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
#' @section Series identity and keys:
#' A task may have one or more `key` columns. Together they identify each series, where identity is
#' the combination of the keys. The key role drives all per-series operations. Target lags and
#' rolling windows ([PipeOpFcstLags], [PipeOpFcstRolling]) are computed within each series, and the
#' future forecast grid is built per series.
#'
#' Key columns are **also** features by default, which is usually what you want. Keys such as
#' `region` or `product` are meaningful categorical covariates, and exposing them lets a global model
#' specialize per series. For a high-cardinality key, such as an arbitrary series id with many
#' levels, passing the raw factor to the learner can overfit or fail for learners that need encoding.
#' Encode it inside the learner graph instead, e.g. with [mlr3pipelines::PipeOpEncodeImpact]
#' (`po("encodeimpact")`) or a shrinkage encoder such as `po("encodelmer")`. Both compose into the
#' [RecursiveForecaster] and [DirectForecaster] graphs. Drop a key's feature role only when it
#' carries no signal beyond identifying the series. The key role, and thus grouping, is kept:
#'
#' ```r
#' task$set_col_roles("series_id", remove_from = "feature")
#' ```
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
#' task = as_task_fcst(airpassengers, target = "passengers", order = "month", freq = "month")
#' task$task_type
#' task$formula()
#' task$truth()
TaskFcst = R6Class(
  "TaskFcst",
  inherit = TaskRegr,
  public = list(
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
      key = character(),
      freq = NULL,
      label = NA_character_,
      extra_args = list()
    ) {
      super$initialize(id = id, backend = backend, target = target, label = label, extra_args = extra_args)
      self$task_type = "fcst"
      private$.freq = assert_freq(freq)

      assert_string(order)
      assert_character(key, any.missing = FALSE)
      col_roles = self$col_roles
      col_roles$order = order
      col_roles$key = key
      col_roles$feature = setdiff(col_roles$feature, order)
      self$col_roles = col_roles
      self$extra_args = insert_named(self$extra_args, list(order = order, key = key, freq = freq))
    },

    #' @description
    #' Returns a slice of the data from the [mlr3::DataBackend] as a [data.table::data.table()].
    #' Rows default to observations with role `"use"`, and columns default to features with roles
    #' `"target"`, `"order"`, `"key"` or `"feature"`. If `rows` or `cols` are specified which do not
    #' exist in the [mlr3::DataBackend], an exception is raised.
    #'
    #' Rows and columns are returned in the order specified via the arguments `rows` and `cols`.
    #' If `rows` is `NULL`, rows are returned in the order of `task$row_ids`.
    #' If `cols` is `NULL`, the column order defaults to `c(task$target_names, task$feature_names,
    #' task$col_roles$key, task$col_roles$order)`.
    #' Note that it is recommended to **not** rely on the order of columns, and instead always
    #' address columns with their respective column name.
    #'
    #' @param ordered (`logical(1)`)\cr
    #'   If `TRUE`, data is ordered according to the columns with column role `"order"` and `"key"`.
    #'
    #' @return A [data.table::data.table()].
    view = function(rows = NULL, cols = NULL, ordered = FALSE) {
      assert_has_backend(self)
      assert_flag(ordered)

      col_roles = self$col_roles
      order_cols = c(col_roles$key, col_roles$order)

      if (is.null(cols)) {
        cols = c(col_roles$target, col_roles$feature)
      } else {
        assert_subset(cols, self$col_info$id)
      }
      cols = union(cols, order_cols)

      data = self$data(rows, cols)
      if (ncol(data) == 0L) {
        return(data)
      }

      if (ordered) {
        setorderv(data, order_cols)
      }
      setcolorder(data, order_cols)
      data[]
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function(...) {
      super$print()
      if (!is.null(self$freq)) {
        cat_cli(cli::cli_li("Frequency: {self$freq}"))
      }
    }
  ),

  active = list(
    #' @field freq (`character(1)` | `numeric(1)` | `NULL`)\cr
    #' The frequency of the time series.
    freq = function(rhs) {
      assert_ro_binding(rhs)
      private$.freq
    },

    #' @field properties (`character()`)\cr
    #' Set of task properties.
    #' Possible properties are stored in [mlr_reflections$task_properties][mlr3::mlr_reflections].
    #' The following properties are currently standardized and understood by tasks in \CRANpkg{mlr3}:
    #'
    #' * `"strata"`: The task is resampled using one or more stratification variables (role `"stratum"`).
    #' * `"groups"`: The task comes with grouping/blocking information (role `"group"`).
    #' * `"weights_learner"`: The task comes with observation weights for the learner (role `"weights_learner"`).
    #' * `"weights_measure"`: The task comes with observation weights for the measure (role `"weights_measure"`).
    #' * `"offset"`: The task comes with offset information (role `"offset"`).
    #' * `"ordered"`: The task has columns which define the row order (role `"order"`).
    #' * `"keys"`: The task has columns which define the time series `"key"`.
    #'
    #' Note that above listed properties are calculated from the `$col_roles` and may not be set explicitly.
    properties = function(rhs) {
      assert_ro_binding(rhs)
      c(super$properties, if (length(self$col_roles$key) > 0L) "keys")
    },

    #' @field order ([data.table::data.table()])\cr
    #' A table with two columns:
    #'
    #' * `row_id` (`integer()`), and
    #' * `order` (`Date()` | `POSIXct()` | `integer()` | `numeric()`).
    order = function(rhs) {
      assert_has_backend(self)
      assert_ro_binding(rhs)
      order_cols = self$col_roles$order
      data = self$backend$data(private$.row_roles$use, c(self$backend$primary_key, order_cols))
      setnames(data, c("row_id", "order"))[]
    },

    #' @field key ([data.table::data.table()] | `NULL`)\cr
    #' If the task has a column with designated role `"key"`, a table with two or more columns:
    #'
    #' * `row_id` (`integer()`), and
    #' * key variable(s) (`factor()` | `ordered()`).
    #'
    #' If there is only one key column, it will be named as `key`.
    #' Returns `NULL` if there are no key columns.
    key = function(rhs) {
      assert_has_backend(self)
      assert_ro_binding(rhs)
      key_cols = self$col_roles$key
      if (length(key_cols) == 0L) {
        return()
      }

      data = self$backend$data(private$.row_roles$use, c(self$backend$primary_key, key_cols))
      if (length(key_cols) == 1L) {
        setnames(data, c("row_id", "key"))[]
      } else {
        setnames(data, c("row_id", key_cols))[]
      }
    }
  ),

  private = list(
    .freq = NULL
  )
)

#' @export
task_check_col_roles.TaskFcst = function(task, new_roles, ...) {
  order_cols = new_roles[["order"]]
  if (length(order_cols) > 1L) {
    error_input("There may only be up to one column with role 'order'")
  }

  if (length(order_cols) > 0L && order_cols %in% new_roles[["target"]]) {
    error_input("Order column '%s' may not also be the target column", order_cols)
  }

  if (length(order_cols) > 0L && order_cols %in% new_roles[["feature"]]) {
    error_input("Order column '%s' may not also be a feature column", order_cols)
  }

  if (
    length(order_cols) > 0L &&
      any(fget_keys(task$col_info, order_cols, "type", key = "id") %nin% c("Date", "POSIXct", "integer", "numeric"))
  ) {
    error_input("Order column '%s' must be a Date, POSIXct, numeric or integer column", order_cols)
  }

  key_cols = new_roles[["key"]]
  if (
    length(key_cols) > 0L && any(fget_keys(task$col_info, key_cols, "type", key = "id") %nin% c("factor", "ordered"))
  ) {
    error_input("Key column(s) %s must be factor or ordered columns", paste0("'", key_cols, "'", collapse = ", "))
  }

  NextMethod()
}
