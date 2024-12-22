#' @title Forecaster
#'
#' @export
Forecaster = R6::R6Class("Forecaster",
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
    #' @returns [Prediction].
    predict = function(task, row_ids = NULL) {
      task = assert_task(as_task(task))
      row_ids = assert_integerish(row_ids,
        lower = 1L, any.missing = FALSE, coerce = TRUE, null.ok = TRUE
      )
      has_row_ids = !is.null(row_ids)
      row_ids = row_ids %??% task$row_ids

      row_ids = sort(row_ids)
      if (!all(diff(row_ids) == 1L)) {
        stopf("Row ids must be consecutive")
      }

      if (has_row_ids) {
        new_task = task$clone()$filter(setdiff(task$row_ids, row_ids))
        new_data = new_task$data()
      } else {
        new_data = task$data()
      }
      n = length(row_ids)
      target = task$target_names
      preds = private$.predict_recursive(new_data, target, n)
      preds$data$truth = task$clone()$filter(row_ids)$data()[[target]]
      preds
    },

    #' @description
    #' Uses the model fitted during `$train()` to create a new [Prediction] based on the forecast horizon `n`.
    #'
    #' @param task ([Task]).
    #' @param n (`integer(1)`).
    #'
    #' @returns [Prediction].
    predict_newdata = function(task, n) {
      task = assert_task(as_task(task))
      n = assert_int(n, lower = 1L, coerce = TRUE)

      preds = private$.predict_recursive(task$data(), task$target_names, n)
      preds$data$truth = rep(NA_real_, n)
      preds
    }
  ),

  private = list(
    .train = function(task) {
      target = task$target_names
      dt = task$data()
      dt = private$.lag_transform(dt, target)
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
      dt[, (nms) := shift(..target, n = lag, type = "lag")]
      dt = dt[(lag[length(lag)] + 1L):.N]
      dt
    },

    .predict_recursive = function(dt, target, n) {
      # one model for all steps
      preds = vector("list", n)
      for (i in seq_len(n)) {
        new_x = private$.lag_transform(dt, target)
        pred = self$model$learner$predict_newdata(new_x[.N, ])
        preds[[i]] = pred
        dt = rbind(dt, pred$response, use.names = FALSE)
      }
      preds = do.call(c, preds)
      preds$data$row_ids = seq_len(n)
      preds
    },

    .predict_direct = function(dt, n) {
      # one model for each step
      .NotYetImplemented()
    }
  )
)
