#' @title Scale the Target Variable
#' @name mlr_pipeops_fcst.targetscale
#'
#' @description
#' Centers and scales the target variable, producing the new target `(y - center) / scale`.
#' On keyed (multi-series) tasks each series is centered and scaled with its own statistics,
#' putting all series on a comparable scale for a global model.
#' The transformation is affine and monotonic,
#' so no rows are dropped and predictions, including quantiles, are inverted pointwise back to the original scale.
#' Standard errors are multiplied by the scale.
#' Predicting a series not seen during training is an error.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTargetTrafo], as well as the following:
#' * `center` :: `logical(1)`\cr
#'   Whether to center the target by subtracting its mean (median if `robust`).
#'   Default `TRUE`.
#' * `scale` :: `logical(1)`\cr
#'   Whether to divide the target by its root-mean-square (median absolute deviation if `robust`),
#'   computed after centering.
#'   Constant series are left unscaled.
#'   Default `TRUE`.
#' * `robust` :: `logical(1)`\cr
#'   Whether to center and scale with the median and median absolute deviation instead of the mean and
#'   root-mean-square.
#'   Default `FALSE`.
#'
#' @section Limitations:
#' This PipeOp must not be placed *inside* a [RecursiveForecaster] graph and is rejected at construction.
#' Inside a [DirectForecaster] graph it works,
#' but each horizon's model computes its own statistics from the rows it is trained on.
#' Use it inside a plain [mlr3pipelines::GraphLearner] via `ppl("targettrafo", ...)`,
#' or wrap the forecaster itself with `ppl("targettrafo", ...)` so all horizons share the same statistics.
#'
#' @export
#' @examples
#' \donttest{
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#' flrn = as_learner(ppl("targettrafo",
#'   graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
#'   trafo_pipeop = po("fcst.targetscale")
#' ))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#' }
PipeOpTargetTrafoScale = R6Class(
  "PipeOpTargetTrafoScale",
  inherit = PipeOpTargetTrafo,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.targetscale"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.targetscale", param_vals = list()) {
      param_set = ps(
        center = p_lgl(init = TRUE, tags = c("train", "required")),
        scale = p_lgl(init = TRUE, tags = c("train", "required")),
        robust = p_lgl(init = FALSE, tags = c("train", "required"))
      )

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
      pv = self$param_set$get_values(tags = "train")
      target = task$target_names
      key_cols = task$col_roles$key
      if (length(key_cols) == 0L) {
        return(scale_stats(task$data(cols = target)[[1L]], pv))
      }
      dt = task$data(cols = c(key_cols, target))
      stats = dt[, scale_stats(get(target), pv), by = key_cols]
      list(key_cols = key_cols, stats = stats)
    },

    .transform = function(task, phase) {
      target = task$target_names
      new_col = paste0(target, ".scaled")
      stats = self$state$stats
      if (is.null(stats)) {
        x = task$data(cols = target)[[1L]]
        new_target = setDT(set_names(list((x - self$state$center) / self$state$scale), new_col))
        task$cbind(new_target)
      } else {
        key_cols = self$state$key_cols
        pk = task$backend$primary_key
        dt = task$backend$data(rows = task$row_ids, cols = c(pk, target, key_cols))
        if (phase == "predict") {
          assert_seen_keys(stats, dt, key_cols)
        }
        dt = stats[dt, on = key_cols]
        set(dt, j = new_col, value = (dt[[target]] - dt$center) / dt$scale)
        task$cbind(dt[, c(pk, new_col), with = FALSE])
      }
      convert_task(task, target = new_col, drop_original_target = TRUE)
    },

    .train_invert = function(task) {
      fcst_invert_state(task)
    },

    .invert = function(prediction, predict_phase_state) {
      response = prediction$data$response
      se = prediction$data$se
      quantiles = prediction$data$quantiles
      stats = self$state$stats

      if (is.null(stats)) {
        center = self$state$center
        scale = self$state$scale
      } else {
        key_cols = self$state$key_cols
        # recover each prediction row's series and invert it with that series' statistics
        dt = predict_phase_state$layout[
          data.table(..row_id = prediction$row_ids, ..pos = seq_along(prediction$row_ids)),
          on = "..row_id"
        ]
        dt = stats[dt, on = key_cols]
        setorderv(dt, "..pos")
        center = dt$center
        scale = dt$scale
      }

      if (!is.null(response)) {
        response = response * scale + center
      }
      if (!is.null(se)) {
        se = se * scale
      }
      inverted = NULL
      if (!is.null(quantiles)) {
        # a matrix times a vector recycles column-major, applying each row's scale and center
        inverted = matrix(
          quantiles * scale + center,
          nrow = nrow(quantiles),
          ncol = ncol(quantiles),
          dimnames = dimnames(quantiles)
        )
        resp_col = attr(quantiles, "response")
        setattr(inverted, "probs", attr(quantiles, "probs"))
        if (length(resp_col) > 0L) {
          setattr(inverted, "response", as.numeric(sub("^q", "", resp_col)))
        }
        response = response %??% inverted[, resp_col]
      }
      PredictionFcst$new(
        row_ids = prediction$row_ids,
        truth = predict_phase_state$truth,
        response = response,
        se = se,
        quantiles = inverted,
        weights = prediction$weights,
        extra = prediction$data$extra,
        col_roles = prediction$data$col_roles
      )
    }
  )
)

scale_stats = function(y, pv) {
  y = y[!is.na(y)]
  center = if (pv$center) (if (pv$robust) stats::median(y) else mean(y)) else 0
  if (!is.finite(center)) {
    center = 0
  }
  scale = 1
  if (pv$scale) {
    scale = if (pv$robust) {
      stats::mad(y, center = center)
    } else {
      sqrt(sum((y - center)^2) / max(length(y) - 1L, 1L))
    }
    # constant series cannot anchor a scale
    if (!is.finite(scale) || scale == 0) {
      scale = 1
    }
  }
  list(center = center, scale = scale)
}

#' @include zzz.R
register_po("fcst.targetscale", PipeOpTargetTrafoScale)
