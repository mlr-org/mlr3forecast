#' @title Abstract Base Class for Iterative Forecasting PipeOps
#' @name PipeOpFcstIterative
#'
#' @description
#' Abstract base class for [PipeOps][mlr3pipelines::PipeOp] that participate in recursive
#' (iterative one-step-ahead) forecasting within [RecursiveForecaster]. Subclasses compute
#' time-dependent features (lags, rolling windows, etc.) from the full task backend rather than
#' only from rows in `row_roles$use`, so that predictions written into the backend by
#' [RecursiveForecaster] between steps are visible on the next iteration.
#'
#' [RecursiveForecaster] detects participating PipeOps via `inherits(po, "PipeOpFcstIterative")`.
#'
#' @section Subclasses:
#' * [mlr_pipeops_fcst.lags] ([PipeOpFcstLags])
#' * [mlr_pipeops_fcst.rolling] ([PipeOpFcstRolling])
#'
#' @export
PipeOpFcstIterative = R6Class(
  "PipeOpFcstIterative",
  inherit = PipeOpTaskPreproc
)
