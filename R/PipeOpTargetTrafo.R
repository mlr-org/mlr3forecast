#' @title Difference the Target Variable
#' @name mlr_pipeops_fcst.targetdiff
#'
#' @description
#' Differences the target variable with lag `lag`, producing the new target `y'_t = y_t - y_{t - lag}`. The first `lag`
#' rows are dropped during training. Predictions are inverted via stride-`lag` cumulative sums anchored at the last
#' `lag` training values, yielding original-scale predictions. On keyed (multi-series) tasks all of this happens within
#' each series: per-series tails anchor the inversion, series too short for the requested lag are dropped with a
#' warning, and predicting series not seen during training is an error.
#'
#' Use `lag = 1` to remove a trend and `lag = 12` (or the seasonal period) to remove seasonality.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTargetTrafo], as well as the following:
#' * `lag` :: `integer(1)`\cr
#'   Lag to difference at. Default `1L`.
#'
#' @section Limitations:
#' This PipeOp must not be placed *inside* a [RecursiveForecaster] or [DirectForecaster] graph and is rejected at
#' construction. Inside [RecursiveForecaster], the trafo only transforms the active row at predict time while iterative
#' features (lags, rolling windows) need transformed values for all historical rows. Inside [DirectForecaster], each
#' horizon is inverted independently against the training tail, which is wrong for horizons >= 2. Use inside a plain
#' [mlr3pipelines::GraphLearner] via `ppl("targettrafo", ...)` for batch prediction, or wrap the forecaster itself with
#' `ppl("targettrafo", ...)` so all horizons are inverted together.
#'
#' Quantile predictions cannot be inverted and are rejected. Differencing is not a pointwise transform, so marginal
#' quantiles of the differenced target do not map back to the original scale (they would only be exact one step ahead).
#'
#' @export
#' @examples
#' \donttest{
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#' flrn = as_learner(ppl("targettrafo",
#'   graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
#'   trafo_pipeop = po("fcst.targetdiff", lag = 1L)
#' ))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#' }
PipeOpTargetTrafoDifference = R6Class(
  "PipeOpTargetTrafoDifference",
  inherit = PipeOpTargetTrafo,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.targetdiff"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.targetdiff", param_vals = list()) {
      param_set = ps(
        lag = p_int(1L, tags = c("train", "required"))
      )
      param_set$set_values(lag = 1L)

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        task_type_in = "TaskRegr",
        tags = "fcst"
      )
    }
  ),

  private = list(
    .get_state = function(task) {
      lag = self$param_set$get_values(tags = "train")$lag
      key_cols = task$col_roles$key
      if (length(key_cols) == 0L) {
        target = task$data(cols = task$target_names)[[1L]]
        return(list(tail = tail(target, lag)))
      }
      dt = task$data(cols = c(key_cols, task$col_roles$order, task$target_names))
      setorderv(dt, c(key_cols, task$col_roles$order))
      tails = dt[, tail(.SD, lag), by = key_cols, .SDcols = task$target_names]
      # series shorter than lag cannot anchor the inversion and are treated as unseen at predict
      tails = tails[, if (.N == lag) .SD, by = key_cols]
      list(key_cols = key_cols, tails = tails)
    },

    .transform = function(task, phase) {
      lag = self$param_set$get_values(tags = "train")$lag
      target = task$target_names
      key_cols = task$col_roles$key
      order_cols = task$col_roles$order

      if (length(key_cols) == 0L) {
        if (length(order_cols) > 0L && is.unsorted(task$data(cols = order_cols)[[1L]])) {
          error_input("%s requires the task to be ordered by its order column.", self$id)
        }
        x = task$data(cols = target)[[1L]]
        if (phase == "predict") {
          x = c(self$state$tail, x)
        }
        new_target = as.data.table(diff(x, lag = lag))
        setnames(new_target, paste0(target, ".diff"))
        if (phase == "train") {
          task$filter(tail(task$row_ids, -lag))
        }
        task$cbind(new_target)
        return(convert_task(task, target = names(new_target), drop_original_target = TRUE))
      }

      pk = task$backend$primary_key
      dt = task$backend$data(rows = task$row_ids, cols = c(pk, target, key_cols, order_cols))
      if (length(order_cols) > 0L && any(dt[, is.unsorted(get(order_cols)), by = key_cols]$V1)) {
        error_input("%s requires each series to be ordered by the order column.", self$id)
      }
      diff_col = paste0(target, ".diff")
      setorderv(dt, c(key_cols, order_cols))
      if (phase == "train") {
        dt[, (diff_col) := get(target) - shift(get(target), lag), by = key_cols]
        kept = fcst_drop_incomplete(dt, diff_col, key_cols)
        task$filter(kept[[pk]])$cbind(kept[, c(pk, diff_col), with = FALSE])
      } else {
        tails = self$state$tails
        assert_seen_keys(tails, dt, key_cols)
        # tail pseudo-rows carry NA pk and precede each series' predict rows after the sort above
        aug = rbind(tails, dt, fill = TRUE)
        aug[, (diff_col) := get(target) - shift(get(target), lag), by = key_cols]
        out = aug[!is.na(get(pk))]
        task$cbind(out[, c(pk, diff_col), with = FALSE])
      }
      convert_task(task, target = diff_col, drop_original_target = TRUE)
    },

    .train_invert = function(task) {
      fcst_invert_state(task)
    },

    .invert = function(prediction, predict_phase_state) {
      if (!is.null(prediction$data$quantiles)) {
        error_input("%s does not support inverting quantile predictions.", self$id)
      }

      lag = self$param_set$get_values(tags = "train")$lag
      tails = self$state$tails
      if (is.null(tails)) {
        inverted = stats::diffinv(prediction$response, lag = lag, xi = self$state$tail)
        inverted = inverted[-seq_len(lag)]
      } else {
        key_cols = self$state$key_cols
        target = setdiff(names(tails), key_cols)
        # regroup prediction rows by series and invert each against its own tail
        dt = predict_phase_state$layout[
          data.table(..row_id = prediction$row_ids, ..pos = seq_along(prediction$row_ids)),
          on = "..row_id"
        ]
        order_cols = setdiff(names(predict_phase_state$layout), c(key_cols, "..row_id"))
        setorderv(dt, c(key_cols, order_cols))
        xis = tails[, list(.xi = list(get(target))), by = key_cols]
        groups = dt[, list(.pos = list(..pos)), by = key_cols]
        groups = xis[groups, on = key_cols]
        inverted = numeric(length(prediction$response))
        for (i in seq_row(groups)) {
          jj = groups$.pos[[i]]
          inverted[jj] = tail(stats::diffinv(prediction$response[jj], lag = lag, xi = groups$.xi[[i]]), -lag)
        }
      }
      PredictionFcst$new(
        row_ids = prediction$row_ids,
        truth = predict_phase_state$truth,
        response = inverted,
        weights = prediction$weights,
        extra = prediction$data$extra
      )
    }
  )
)

#' @include zzz.R
register_po("fcst.targetdiff", PipeOpTargetTrafoDifference)
