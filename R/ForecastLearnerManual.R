#' @title Forecast Learner Manual
#'
#' @description
#' The [ForecastLearnerManual] wraps a [mlr3::Learner].
#'
#' @export
ForecastLearnerManual = R6::R6Class(
  "ForecastLearnerManual",
  inherit = Learner,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param learner ([mlr3::Learner])\cr
    #'   The regression learner to wrap.
    initialize = function(learner) {
      private$.learner = assert_learner(as_learner(learner, clone = TRUE))

      super$initialize(
        id = learner$id,
        task_type = "regr",
        param_set = learner$param_set,
        predict_types = learner$predict_types,
        feature_types = learner$feature_types,
        properties = learner$properties,
        packages = c("mlr3forecast", learner$packages),
        man = learner$man
      )
    }
  ),

  active = list(
    #' @field learner ([mlr3::Learner])\cr
    #' The wrapped learner.
    learner = function(rhs) {
      assert_ro_binding(rhs)
      private$.learner
    }
  ),

  private = list(
    .learner = NULL,
    .train = function(task) {
      target = task$target_names
      dt = task$data()
      new_task = as_task_regr(dt, target = target)
      learner = self$learner$clone(deep = TRUE)$train(new_task)
      structure(list(learner = learner), class = c("forecast_learner_model", "list"))
    },

    .predict = function(task) {
      target = task$target_names
      dt = task$data()
      lags = grep(sprintf("%s_lag_[0-9]+$", target), names(dt), value = TRUE)
      if (length(lags) == 0L) {
        stopf("No lag columns found.")
      }
      lags = sort(as.integer(sub(sprintf("%s_lag_", target), "", lags, fixed = TRUE)))
      max_lag = max(lags)

      n = task$nrow
      preds = vector("list", length = n)
      for (i in seq_len(n)) {
        pred = self$model$learner$predict_newdata(dt[i])
        preds[[i]] = pred
        set(dt, i = i, j = target, value = pred$response)
        ii = which(lags == min(i, max_lag))
        lag = lags[seq_len(ii)]
        lag_cols = sprintf("%s_lag_%i", target, lag)
        dt[, (lag_cols) := shift(get(target), lag)]
      }
      preds = do.call(c, preds)
      preds$data$row_ids = seq_len(n)
      preds
    }
  )
)
