#' @title Unite Per-Series Forecasts into One Prediction
#' @name mlr_pipeops_fcst.unitekey
#'
#' @description
#' Row-binds a [Multiplicity][mlr3pipelines::Multiplicity] of per-series [PredictionFcst]s, as
#' created downstream of [`po("fcst.splitkey")`][mlr_pipeops_fcst.splitkey], into a single
#' [PredictionFcst].
#'
#' The series identity is rebuilt from the multiplicity names as a factor column in the
#' prediction's `extra` slot, so `$key`, `as.data.table()`, and [autoplot.PredictionFcst()] keep
#' working. Set `key` to the task's key column name to get predictions column-compatible with global
#' forecasters such as [RecursiveForecaster], which attach the original key column.
#'
#' @section Parameters:
#' * `key` :: `character(1)`\cr
#'   Name of the rebuilt series-identity column in the prediction's `extra` slot. Default `"key"`.
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
PipeOpFcstUniteKey = R6Class(
  "PipeOpFcstUniteKey",
  inherit = PipeOp,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.unitekey"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.unitekey", param_vals = list()) {
      param_set = ps(
        key = p_uty(
          tags = "predict",
          custom_check = crate(function(x) check_string(x, min.chars = 1L))
        )
      )
      param_set$set_values(key = "key")

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        input = data.table(name = "input", train = "[NULL]", predict = "[PredictionFcst]"),
        output = data.table(name = "output", train = "NULL", predict = "PredictionFcst"),
        tags = c("multiplicity", "fcst")
      )
    }
  ),

  private = list(
    .train = function(inputs) {
      self$state = list()
      list(NULL)
    },

    .predict = function(inputs) {
      inputs = unclass(inputs[[1L]])
      if (length(inputs) == 0L) {
        error_input("%s received an empty multiplicity.", self$id)
      }
      labels = names(inputs)
      if (!test_names(labels, type = "unique")) {
        error_input("%s requires a named multiplicity, as created by po(\"fcst.splitkey\").", self$id)
      }
      pdatas = map(inputs, "data")
      pdata = if (length(pdatas) == 1L) pdatas[[1L]] else invoke(c, .args = unname(pdatas))
      extra = as.list(pdata$extra)
      if (!any(map_lgl(extra, is.factor))) {
        key = self$param_set$get_values(tags = "predict")$key
        if (key %in% names(extra)) {
          error_input(
            "%s cannot rebuild the series identity as '%s': the prediction already carries an extra column with that name.",
            self$id,
            key
          )
        }
        # rebuild the series identity dropped by fcst.splitkey from the multiplicity names
        counts = map_int(pdatas, function(x) length(x$row_ids))
        extra[[key]] = factor(rep(labels, counts), levels = labels)
        pdata$extra = extra
      }
      list(as_prediction(pdata, check = FALSE))
    }
  )
)

#' @include zzz.R
register_po("fcst.unitekey", PipeOpFcstUniteKey)
