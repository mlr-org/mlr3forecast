#' @title Box-Cox Transform the Target Variable
#' @name mlr_pipeops_fcst.targetboxcox
#'
#' @description
#' Applies a Box-Cox transformation to the target variable to stabilize the variance, producing the new target
#' `BoxCox(y, lambda)`. The transformation is pointwise and monotonic, so no rows are dropped and predictions are
#' inverted via [forecast::InvBoxCox()].
#'
#' `lambda = 0` is the log transformation. When `lambda` is `NULL` (default) it is estimated from the training data
#' via [forecast::BoxCox.lambda()], using the task frequency for the `"guerrero"` method so seasonality is accounted
#' for. The estimated (or supplied) `lambda` is stored and reused at predict time and for inversion. On keyed
#' (multi-series) tasks a separate `lambda` is estimated per series and each row is transformed and inverted with its
#' series' `lambda`; predicting series not seen during training is then an error. A supplied `lambda` applies to all
#' series.
#'
#' Box-Cox and log transformations require strictly positive target values. Non-positive values produce `NaN` or an
#' error from [forecast::BoxCox()].
#'
#' A negative `lambda` (possible when estimated, as `lower` defaults to `-1`) makes [forecast::InvBoxCox()] return `NA`
#' for back-transformed values above `-1 / lambda`, typically upper quantiles. Set `lower = 0` to avoid this.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTargetTrafo], as well as the following:
#' * `lambda` :: `numeric(1)` | `NULL`\cr
#'   Box-Cox transformation parameter. `NULL` (default) estimates it from the training data, `0` is the log
#'   transformation, any other numeric is used as a fixed value.
#' * `method` :: `character(1)`\cr
#'   Method used to estimate `lambda` when `lambda = NULL`, one of `"guerrero"` (default) or `"loglik"`. See
#'   [forecast::BoxCox.lambda()].
#' * `lower` :: `numeric(1)`\cr
#'   Lower bound for the estimated `lambda`. Default `-1`.
#' * `upper` :: `numeric(1)`\cr
#'   Upper bound for the estimated `lambda`. Default `2`.
#'
#' @section Limitations:
#' This PipeOp must not be placed *inside* a [RecursiveForecaster] or [DirectForecaster] graph. Inside
#' [RecursiveForecaster] the transformation would entangle with the iterative lag/rolling feedback, which reads the
#' original-scale backend, producing a train/predict scale mismatch (rejected at construction). Use inside a plain
#' [mlr3pipelines::GraphLearner] via `ppl("targettrafo", ...)` for batch prediction, or wrap the forecaster itself with
#' `ppl("targettrafo", ...)` so all horizons are inverted together.
#'
#' @export
#' @examples
#' \donttest{
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#' flrn = as_learner(ppl("targettrafo",
#'   graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
#'   trafo_pipeop = po("fcst.targetboxcox")
#' ))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#' }
PipeOpTargetTrafoBoxCox = R6Class(
  "PipeOpTargetTrafoBoxCox",
  inherit = PipeOpTargetTrafo,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.targetboxcox"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.targetboxcox", param_vals = list()) {
      param_set = ps(
        lambda = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        method = p_fct(c("guerrero", "loglik"), default = "guerrero", tags = c("train", "estimate")),
        lower = p_dbl(default = -1, tags = c("train", "estimate")),
        upper = p_dbl(default = 2, tags = c("train", "estimate"))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines", "forecast"),
        task_type_in = "TaskRegr",
        tags = "fcst"
      )
    }
  ),

  private = list(
    .get_state = function(task) {
      lambda = self$param_set$get_values(tags = "train")$lambda
      key_cols = task$col_roles$key
      if (!is.null(lambda) || length(key_cols) == 0L) {
        if (is.null(lambda)) {
          lambda = invoke(forecast::BoxCox.lambda, as.ts(task), .args = self$param_set$get_values(tags = "estimate"))
        }
        return(list(lambda = lambda))
      }
      target = task$target_names
      period = freq_to_period(task$freq)
      args = self$param_set$get_values(tags = "estimate")
      estimate_lambda = function(y) {
        invoke(forecast::BoxCox.lambda, stats::ts(as.numeric(y), frequency = period), .args = args)
      }
      dt = task$data(cols = c(key_cols, task$col_roles$order, target))
      setorderv(dt, c(key_cols, task$col_roles$order))
      lambdas = dt[, list(lambda = estimate_lambda(get(target))), by = key_cols]
      list(key_cols = key_cols, lambdas = lambdas)
    },

    .transform = function(task, phase) {
      target = task$target_names
      bc_col = paste0(target, ".bc")
      lambdas = self$state$lambdas
      if (is.null(lambdas)) {
        x = task$data(cols = target)[[1L]]
        new_target = as.data.table(as.numeric(forecast::BoxCox(x, self$state$lambda)))
        setnames(new_target, bc_col)
        task$cbind(new_target)
      } else {
        key_cols = self$state$key_cols
        pk = task$backend$primary_key
        dt = task$backend$data(rows = task$row_ids, cols = c(pk, target, key_cols))
        if (phase == "predict") {
          fcst_assert_seen_keys(unique(key_labels(lambdas, key_cols)), dt, key_cols)
        }
        dt = lambdas[dt, on = key_cols]
        # BoxCox only supports a scalar lambda, so transform each series with its own value
        dt[, (bc_col) := as.numeric(forecast::BoxCox(get(target), lambda[1L])), by = key_cols]
        task$cbind(dt[, c(pk, bc_col), with = FALSE])
      }
      convert_task(task, target = bc_col, drop_original_target = TRUE)
    },

    .train_invert = function(task) {
      fcst_invert_state(task)
    },

    .invert = function(prediction, predict_phase_state) {
      response = prediction$data$response
      quantiles = prediction$data$quantiles
      lambdas = self$state$lambdas

      if (is.null(lambdas)) {
        lambda = self$state$lambda
        if (!is.null(response)) {
          response = invoke(forecast::InvBoxCox, response, lambda = lambda)
        }
        # Box-Cox is monotonic, so quantiles invert pointwise without crossing
        if (!is.null(quantiles)) {
          inverted_values = invoke(forecast::InvBoxCox, quantiles, lambda = lambda)
        }
      } else {
        key_cols = self$state$key_cols
        # recover each prediction row's series and invert it with that series' lambda
        dt = predict_phase_state$layout[
          data.table(..row_id = prediction$row_ids, ..pos = seq_along(prediction$row_ids)),
          on = "..row_id"
        ]
        dt = lambdas[dt, on = key_cols]
        groups = split(dt$..pos, key_labels(dt, key_cols))
        group_lambdas = map_dbl(split(dt$lambda, key_labels(dt, key_cols)), 1L)
        inverted_values = quantiles
        for (label in names(groups)) {
          jj = groups[[label]]
          lambda = group_lambdas[[label]]
          if (!is.null(response)) {
            response[jj] = as.numeric(forecast::InvBoxCox(response[jj], lambda = lambda))
          }
          if (!is.null(quantiles)) {
            inverted_values[jj, ] = forecast::InvBoxCox(quantiles[jj, , drop = FALSE], lambda = lambda)
          }
        }
      }

      if (!is.null(quantiles)) {
        inverted = matrix(
          inverted_values,
          nrow = nrow(quantiles),
          ncol = ncol(quantiles),
          dimnames = dimnames(quantiles)
        )
        resp_col = attr(quantiles, "response")
        setattr(inverted, "probs", attr(quantiles, "probs"))
        if (length(resp_col) > 0L) {
          setattr(inverted, "response", as.numeric(sub("^q", "", resp_col)))
        }
        return(PredictionFcst$new(
          row_ids = prediction$row_ids,
          truth = predict_phase_state$truth,
          response = response %??% inverted[, resp_col],
          quantiles = inverted,
          weights = prediction$weights,
          extra = prediction$data$extra
        ))
      }
      PredictionFcst$new(
        row_ids = prediction$row_ids,
        truth = predict_phase_state$truth,
        response = response,
        weights = prediction$weights,
        extra = prediction$data$extra
      )
    }
  )
)

#' @include zzz.R
register_po("fcst.targetboxcox", PipeOpTargetTrafoBoxCox)
