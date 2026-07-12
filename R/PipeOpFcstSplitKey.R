#' @title Split a Forecast Task into Per-Series Tasks
#' @name mlr_pipeops_fcst.splitkey
#'
#' @description
#' Splits a keyed (multi-series) [TaskFcst] into a [Multiplicity][mlr3pipelines::Multiplicity] of
#' single-series tasks, one per key combination. Subsequent PipeOps are executed once per series
#' until a [`po("fcst.unitekey")`][mlr_pipeops_fcst.unitekey] is reached, fitting one local model
#' per series instead of one global model pooled across series.
#'
#' The per-series tasks carry no key columns, so classical univariate learners (e.g.
#' `lrn("fcst.ets")`) compose as well. The key groups observed during training are stored in the
#' `$state` and the task must contain exactly the same key groups at predict time.
#'
#' @section Parameters:
#' This PipeOp has no parameters.
#'
#' @export
#' @examplesIf requireNamespace("forecast", quietly = TRUE)
#' library(mlr3pipelines)
#' library(data.table)
#' dt = CJ(
#'   month = seq(as.Date("2024-01-01"), by = "month", length.out = 36L),
#'   id = factor(c("a", "b"))
#' )
#' dt[, value := rnorm(.N, mean = fifelse(id == "a", 10, 20))]
#' task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
#' graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
#' flrn = as_learner(graph)$train(task)
#' forecast(flrn, task, 12L)
PipeOpFcstSplitKey = R6Class(
  "PipeOpFcstSplitKey",
  inherit = PipeOp,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.splitkey"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.splitkey", param_vals = list()) {
      super$initialize(
        id = id,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        input = data.table(name = "input", train = "TaskFcst", predict = "TaskFcst"),
        output = data.table(name = "output", train = "[TaskFcst]", predict = "[TaskFcst]"),
        tags = c("multiplicity", "fcst")
      )
    }
  ),

  private = list(
    .train = function(inputs) {
      task = inputs[[1L]]
      split = private$.split_rows(task)
      self$state = list(keys = split$keys, labels = names(split$groups))
      list(as.Multiplicity(imap(split$groups, function(rows, label) private$.subtask(task, rows, label))))
    },

    .predict = function(inputs) {
      task = inputs[[1L]]
      split = private$.split_rows(task)
      keys = split$keys
      train_keys = self$state$keys
      key_cols = task$col_roles$key
      unseen = keys[!train_keys, on = key_cols]
      if (nrow(unseen) > 0L) {
        error_input(
          "Task has key group(s) not seen during training: %s.",
          str_collapse(key_labels(unseen, key_cols), quote = "'")
        )
      }
      missing = train_keys[!keys, on = key_cols]
      if (nrow(missing) > 0L) {
        error_input(
          "Task is missing key group(s) seen during training: %s.",
          str_collapse(key_labels(missing, key_cols), quote = "'")
        )
      }
      # per-series states downstream are matched by name, so keep the training order
      groups = split$groups[self$state$labels]
      list(as.Multiplicity(imap(groups, function(rows, label) private$.subtask(task, rows, label))))
    },

    .split_rows = function(task) {
      if ("keys" %nin% task$properties) {
        error_input("%s requires a task with key columns.", self$id)
      }
      col_roles = task$col_roles
      key_cols = col_roles$key
      dt = task$data(cols = c(key_cols, col_roles$order))
      set(dt, j = "..row_id", value = task$row_ids)
      setorderv(dt, c(key_cols, col_roles$order))
      keys = key_table(dt, key_cols)
      groups = dt[, list(.rows = list(..row_id)), by = key_cols]
      groups = keys[groups, on = key_cols]
      list(groups = set_names(groups$.rows, groups$.label), keys = keys)
    },

    .subtask = function(task, rows, label) {
      subtask = task$clone()
      subtask$id = sprintf("%s.%s", task$id, label)
      # filter keeps the given row order, so each sub-task is chronological
      subtask$filter(rows)
      # the key columns are constant within one series and keyed tasks are
      # rejected by the classical learners, so drop both roles
      subtask$set_col_roles(task$col_roles$key, remove_from = c("key", "feature"))
      subtask$extra_args$key = character()
      subtask
    }
  )
)

#' @include zzz.R
register_po("fcst.splitkey", PipeOpFcstSplitKey)
