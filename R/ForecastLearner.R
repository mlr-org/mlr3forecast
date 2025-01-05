#' @title Forecast Learner
#'
#' @export
ForecastLearner = R6::R6Class("ForecastLearner",
  inherit = Learner,
  public = list(
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
    initialize = function(learner, lag) {
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
    #' @return [Prediction].
    predict = function(task, row_ids = NULL) {
      task = assert_task(as_task(task))
      row_ids = assert_integerish(row_ids,
        lower = 1L, any.missing = FALSE, coerce = TRUE, null.ok = TRUE
      )

      # 1. direct learner$predict(): entire task + row_ids or `NULL` for entire task prediction
      # 2. resampling: test task and `NULL` row_ids, task$row_ids are from entire task
      # 3. glrn$predict(): test task and `NULL` row_ids, task$row_ids are from train task
      # 4. glrn$predict_newdata(): test task and `NULL` row_ids, task$row_ids are 1:n, i.e. not from entire task
      #    NB: this will need some special handling, how do I know if its called by glrn?
      # check for glrn$predict_newdata() case
      has_row_ids = !is.null(row_ids)
      row_ids = row_ids %??% task$row_ids
      row_ids = sort(row_ids)
      if (!has_row_ids &&
        nrow(fintersect(task$data(), private$.task$data())) == 0 &&
        all(task$row_ids %in% private$.task$row_ids)) {
        row_ids = seq_along(row_ids) + tail(private$.task$row_ids, 1L)
      }
      if (is.null(task$key) && !all(diff(row_ids) == 1L)) {
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
    #' @return [Prediction].
    predict_newdata = function(newdata, task) {
      task = assert_task(as_task(task))
      assert_learnable(task, self)
      private$.predict_newdata_recursive(task, newdata)
    }
  ),

  private = list(
    .task = NULL,

    .train = function(task) {
      private$.task = task$clone()
      target = task$target_names
      dt = private$.lag_transform(task$data(), target)
      new_task = as_task_regr(dt, target = target)

      learner = self$learner$clone(deep = TRUE)
      learner$train(new_task)
      structure(list(learner = learner), class = c("forecaster_model", "list"))
    },

    .predict = function(task) {
      self$predict(task)
    },

    .lag_transform = function(dt, target) {
      lag = self$lag
      nms = sprintf("%s_lag_%s", target, lag)
      dt = copy(dt)
      key = private$.task$key
      if (is.null(key)) {
        dt[, (nms) := shift(.SD, n = lag, type = "lag"), .SDcols = target]
      } else {
        setorderv(dt, c(key))
        dt[, (nms) := shift(.SD, n = lag, type = "lag"), by = key, .SDcols = target]
      }
      dt
    },

    .predict_recursive = function(task, row_ids) {
      # join the training task with the prediction task for lag transformation
      # in normal predict we get the entire task, in resampling we only get the subset
      # TODO: check why `Task$data_formats` warning is thrown
      if (suppressWarnings(isTRUE(all.equal(private$.task, task)))) {
        dt = task$data()
      } else {
        dt = rbind(private$.task$data(), task$data())
      }
      target = private$.task$target_names
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

    .predict_newdata_recursive = function(task, newdata) {
      dt = task$data()
      target = task$target_names
      # create a new rows for the new prediction
      dt = rbind(dt, newdata, fill = TRUE)
      row_ids = task$nrow + seq_len(nrow(newdata))
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
