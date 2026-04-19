#' @title Abstract Base Class for Iterative Forecasting PipeOps
#' @name PipeOpFcstIterative
#'
#' @description
#' Abstract base class for [PipeOps][mlr3pipelines::PipeOp] that participate in recursive
#' (iterative one-step-ahead) forecasting within [RecursiveForecaster]. Subclasses maintain a
#' `history` slot in `self$state` and implement (or inherit) `update_history(new_row)`, which
#' appends the most recently predicted row so subsequent prediction steps can compute features
#' from it.
#'
#' [RecursiveForecaster] detects participating PipeOps via `inherits(po, "PipeOpFcstIterative")`.
#'
#' The default `update_history()` implementation appends `new_row` to `self$state$history`, which
#' covers the common case (lag features, rolling-window features). Override in a subclass when a
#' different history representation is needed.
#'
#' @section Subclasses:
#' * [mlr_pipeops_fcst.lags] ([PipeOpFcstLags])
#' * [mlr_pipeops_fcst.rolling] ([PipeOpFcstRolling])
#'
#' @export
PipeOpFcstIterative = R6Class(
  "PipeOpFcstIterative",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description
    #' Append a newly-predicted row to `self$state$history`. Called by [RecursiveForecaster] after
    #' each prediction step. Override to customize history maintenance.
    #' @param new_row ([data.table::data.table()])\cr
    #'   A single-row data.table containing the target (set to the predicted value), order
    #'   columns, and key columns.
    update_history = function(new_row) {
      if (is.null(self$state)) {
        stopf("PipeOp '%s' has no state; train it before calling update_history().", self$id)
      }
      self$state$history = fcst_history_append(self$state$history, new_row)
    }
  )
)
