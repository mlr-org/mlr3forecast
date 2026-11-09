#' @title Forecast Task
#'
#' @description
#' This task specializes [mlr3::TaskRegr] for forecasting problems.
#' The target column must be numeric.
#' The `task_type` is set to `"fcst"`.
#'
#' It is recommended to use [as_task_fcst()] for construction.
#' Predefined tasks are stored in the [dictionary][mlr3misc::Dictionary] [mlr3::mlr_tasks].
#'
#' @section Series identity and keys:
#' A task may have one or more `key` columns whose combination identifies each series.
#' Target lags and rolling windows ([PipeOpFcstLags], [PipeOpFcstRolling]) are computed within each series.
#' The future forecast grid is also built per series.
#'
#' Key columns are **not** features by default.
#' To let a global model specialize per series, add the feature role back:
#'
#' ```r
#' task$set_col_roles("series_id", add_to = "feature")
#' ```
#'
#' Integer keys used as features are treated as numeric values by the learner.
#' Convert them to factors to treat them as categories.
#' For keys with many levels, consider encoding them in the learner graph, e.g. with `po("encodeimpact")`.
#'
#' @template param_id
#' @template param_backend
#' @template param_rows
#' @template param_cols
#'
#' @template seealso_task
#' @export
#' @examplesIf mlr3misc::require_namespaces("tsbox", quietly = TRUE)
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
      assert_string(order)
      assert_character(key, any.missing = FALSE)
      assert_freq(freq, null.ok = TRUE, numeric.ok = TRUE)

      super$initialize(id = id, backend = backend, target = target, label = label, extra_args = extra_args)
      self$task_type = "fcst"
      col_roles = self$col_roles
      col_roles$order = order
      col_roles$key = key
      col_roles$feature = setdiff(col_roles$feature, c(order, key))
      self$col_roles = col_roles
      self$extra_args = insert_named(self$extra_args, list(order = order, key = key))
      self$freq = freq
    },

    #' @description
    #' Returns task data as a [data.table::data.table()], always including the key and order columns first.
    #' By default, selects rows with role `"use"` and columns with roles `"target"` or `"feature"`.
    #' Unknown rows or columns raise an error.
    #'
    #' Rows follow `rows`, or `task$row_ids` if `rows` is `NULL`, unless `ordered = TRUE`.
    #' After the key and order columns, columns follow `cols`, or the target and feature names if `cols` is `NULL`.
    #' Access columns by name rather than position.
    #'
    #' @param ordered (`logical(1)`)\cr
    #'   If `TRUE`, sorts rows by the key columns and then the order column.
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
      cat_cli(cli::cli_li("Frequency: {self$freq}"))
    }
  ),

  active = list(
    #' @field freq (`character(1)` | `numeric(1)`)\cr
    #' The step of the time index, i.e. the spacing between two consecutive observations.
    #' A calendar string for a `Date` or `POSIXct` order column and a number for a numeric or integer one.
    #' Assign a step to set it, which is checked against the order column, or `NULL` to infer it.
    #' A calendar step is stored as `"<n> <unit>"`, e.g. `"1 month"` for `"month"` or `"months"`.
    #' The step is resolved again when the order or key columns change.
    freq = function(rhs) {
      roles = self$col_roles[c("order", "key")]
      if (missing(rhs)) {
        if (!identical(private$.freq_roles, roles)) {
          private$.freq = task_resolve_freq(self, self$extra_args$freq)
          private$.freq_roles = roles
        }
        return(private$.freq)
      }
      assert_freq(rhs, null.ok = TRUE, numeric.ok = TRUE)
      private$.freq = task_resolve_freq(self, rhs)
      private$.freq_roles = roles
      self$extra_args$freq = if (!is.null(rhs)) private$.freq
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
    #' These properties are calculated from `$col_roles` and cannot be set directly.
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
    #' * key variable(s) (`character()` | `integer()` | `factor()` | `ordered()`).
    #'
    #' If there is only one key column, it is named `key`.
    #' Returns `NULL` if there are no key columns.
    key = function(rhs) {
      assert_has_backend(self)
      assert_ro_binding(rhs)
      key_cols = self$col_roles$key
      if (length(key_cols) == 0L) {
        return()
      }

      data = self$backend$data(private$.row_roles$use, c(self$backend$primary_key, key_cols))
      setnames(data, c("row_id", if (length(key_cols) == 1L) "key" else key_cols))[]
    }
  ),

  private = list(
    .freq = NULL,
    .freq_roles = NULL
  )
)

#' @export
task_check_col_roles.TaskFcst = function(task, new_roles, ...) {
  order_cols = new_roles[["order"]]
  target_cols = new_roles[["target"]]
  # parent constructors set roles before the order column exists
  if (length(order_cols) > 1L || (length(order_cols) == 0L && task$task_type == "fcst")) {
    error_input("There must be exactly one column with role 'order'.")
  }

  if (length(order_cols) > 0L) {
    if (order_cols %chin% target_cols) {
      error_input("Order column '%s' may not also be the target column.", order_cols)
    }

    order_type = fget_keys(task$col_info, order_cols, "type", key = "id")
    if (order_type %nin% c("Date", "POSIXct", "integer", "numeric")) {
      error_input("Order column '%s' must be a Date, POSIXct, numeric or integer column.", order_cols)
    }

    if (task$missings(cols = order_cols) > 0L) {
      error_input("Order column '%s' contains missing values.", order_cols)
    }
  }

  key_cols = new_roles[["key"]]
  cols = c(order_cols, key_cols)
  reserved = cols[
    cols %chin% c("row_ids", "truth", "response", "se", "distr", "weights") | grepl("^q[0-9.]+(e[-+]?[0-9]+)?$", cols)
  ]
  if (length(reserved) > 0L) {
    error_input(
      "Order and key column(s) %s may not use reserved prediction column names, rename them.",
      str_collapse(reserved, quote = "'")
    )
  }

  if (length(key_cols) > 0L) {
    if (any(key_cols %chin% order_cols)) {
      error_input(
        "Column(s) %s may not have both the 'order' and the 'key' role.",
        str_collapse(intersect(key_cols, order_cols), quote = "'")
      )
    }

    if (any(key_cols %chin% target_cols)) {
      error_input(
        "Key column(s) %s may not also be the target column.",
        str_collapse(intersect(key_cols, target_cols), quote = "'")
      )
    }

    key_types = fget_keys(task$col_info, key_cols, "type", key = "id")
    if (any(key_types %nin% c("character", "integer", "factor", "ordered"))) {
      error_input(
        "Key column(s) %s must be character, integer, factor, or ordered columns.",
        str_collapse(key_cols, quote = "'")
      )
    }

    key_missings = task$missings(cols = key_cols)
    if (any(key_missings > 0L)) {
      error_input(
        "Key column(s) %s contain missing values.",
        str_collapse(names(key_missings[key_missings > 0L]), quote = "'")
      )
    }
  }

  if (length(order_cols) > 0L) {
    index = task$backend$data(rows = task$row_ids, cols = c(key_cols, order_cols))
    if (anyDuplicated(index) > 0L) {
      error_input("Order column '%s' contains duplicated values within a time series.", order_cols)
    }
  }

  NextMethod()
}

#' @export
as.ts.TaskFcst = function(x, ..., period = NULL) {
  if ("freq" %chin% ...names()) {
    error_input("`as.ts()` no longer takes `freq`. Use `period` for the seasonal period.")
  }
  assert_period(period)
  if (length(x$col_roles$key) > 0L) {
    error_input("Cannot coerce a multi-series (keyed) task to a single ts object.")
  }
  dt = x$data(cols = c(x$col_roles$order, x$target_names), ordered = TRUE)
  frequency = resolve_period(period, x$freq)
  start = 1
  months = calendar_months(x$freq)
  # a calendar cycle of one year places the series on the calendar, e.g. monthly data starting in January 1949
  if (nrow(dt) > 0L && !is.na(months) && 12L %% months == 0L && frequency == 12L %/% months) {
    first = civil_parts(dt[[1L]][1L])
    start = c(first$year, (first$month - 1L) %/% months + 1L)
  }
  stats::ts(dt[[2L]], start = start, frequency = frequency)
}
