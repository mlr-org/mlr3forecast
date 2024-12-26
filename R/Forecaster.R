#' @title Forecaster
#'
#' @export
Forecaster = R6::R6Class("Forecaster",
  inherit = Learner,
  public = list(
    #' @field task ([Task])\cr
    #' The task
    task = NULL,

    #' @field learner ([Learner])\cr
    #' The learner
    learner = NULL,

    #' @field lag (`integer(1)`)\cr
    #' The lag
    lag = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param task ([Task])\cr
    #' @param learner ([Learner])\cr
    #' @param lag (`integer(1)`)\cr
    initialize = function(task, learner, lag) {
      # current workaround for resampling to work, need to build lags on entire task
      self$task = assert_task(as_task(task))
      self$learner = assert_learner(as_learner(learner, clone = TRUE))
      self$lag = assert_integerish(lag, lower = 1L, any.missing = FALSE, coerce = TRUE)

      super$initialize(
        id = learner$id,
        task_type = learner$task_type,
        param_set = learner$param_set,
        predict_types = learner$predict_types,
        feature_types = learner$feature_types,
        properties = learner$properties,
        packages = c("mlr3forecast", learner$packages),
        man = learner$man
      )
    },

    #' @description
    #' Uses the information stored during `$train()` in `$state` to create a new [Prediction]
    #' for a set of observations of the provided `task`.
    #'
    #' @param task ([Task]).
    #'
    #' @param row_ids (`integer()`)\cr
    #'   Vector of test indices as subset of `task$row_ids`. For a simple split
    #'   into training and test set, see [partition()].
    #'
    #' @returns [Prediction].
    predict = function(task, row_ids = NULL) {
      task = assert_task(as_task(task))
      row_ids = assert_integerish(row_ids,
        lower = 1L, any.missing = FALSE, coerce = TRUE, null.ok = TRUE
      )

      row_ids = row_ids %??% task$row_ids
      row_ids = sort(row_ids)
      if (!all(diff(row_ids) == 1L)) {
        stopf("Row ids must be consecutive")
      }
      private$.predict_recursive(task, row_ids)
    },

    #' @description
    #' Uses the model fitted during `$train()` to create a new [Prediction] based on the forecast horizon `n`.
    #'
    #' @param task ([Task]).
    #' @param n (`integer(1)`).
    #' @param newdata (any object supported by [as_data_backend()])\cr
    #'   New data to predict on.
    #'   All data formats convertible by [as_data_backend()] are supported, e.g.
    #'   `data.frame()` or [DataBackend].
    #'   If a [DataBackend] is provided as `newdata`, the row ids are preserved,
    #'   otherwise they are set to to the sequence `1:nrow(newdata)`.
    #'
    #' @returns [Prediction].
    predict_newdata = function(newdata, task) {
      task = assert_task(as_task(task))
      private$.predict_recursive2(task, newdata)
    }
  ),

  private = list(
    .train = function(task) {
      target = task$target_names
      dt = private$.lag_transform(task$data(), target)
      new_task = as_task_regr(dt, target = target)

      learner = self$learner$clone(deep = TRUE)
      learner$train(new_task)

      # the return model is a list of "learner"
      result_model = list(learner = learner)
      structure(result_model, class = c("forecaster_model", "list"))
    },

    .predict = function(task) {
      self$predict(task)
    },

    .lag_transform = function(dt, target) {
      lag = self$lag
      nms = sprintf("%s_lag_%s", target, lag)
      dt = copy(dt)
      dt[, (nms) := shift(.SD, n = lag, type = "lag"), .SDcols = target]
      dt
    },

    .predict_recursive = function(task, row_ids) {
      dt = self$task$data()[seq_len(tail(row_ids, 1L))]
      target = self$task$target_names
      # one model for all steps
      preds = map(row_ids, function(i) {
        new_x = private$.lag_transform(dt, target)[i]
        pred = self$model$learner$predict_newdata(new_x)
        dt[i, (target) := pred$response]
        pred
      })
      preds = do.call(c, preds)
      preds$data$row_ids = seq_len(length(row_ids))
      preds
    },

    .predict_recursive2 = function(task, newdata) {
      dt = self$task$data()
      target = task$target_names
      # create a new rows for the new prediction
      dt = rbind(dt, newdata, fill = TRUE)
      row_ids = self$task$nrow + seq_len(nrow(newdata))
      # one model for all steps
      preds = map(row_ids, function(i) {
        new_x = private$.lag_transform(dt, target)[i]
        pred = self$model$learner$predict_newdata(new_x)
        dt[i, (target) := pred$response]
        pred
      })
      preds = do.call(c, preds)
      preds$data$row_ids = seq_len(nrow(newdata))
      preds
    },

    .predict_direct = function(dt, n) {
      # one model for each step
      .NotYetImplemented()
    }
  )
)
