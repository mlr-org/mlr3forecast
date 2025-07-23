#' @title Forecast Learner
#'
#' @export
ForecastLearner = R6::R6Class(
  "ForecastLearner",
  inherit = Learner,
  public = list(
    #' @field learner ([mlr3::Learner])\cr
    #' The learner
    learner = NULL,

    #' @field lags (`integer()`)\cr
    #' The lags
    lags = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param task ([mlr3::Task])\cr
    #' @param learner ([mlr3::Learner])\cr
    #' @param lags (`integer(1)`)\cr
    initialize = function(learner, lags) {
      self$learner = assert_learner(as_learner(learner, clone = TRUE))
      self$lags = assert_integerish(lags, lower = 1L, any.missing = FALSE, coerce = TRUE)

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

  private = list(
    .task = NULL,
    .max_index = NULL,

    .train = function(task) {
      col_roles = task$col_roles
      order_cols = col_roles$order
      private$.max_index = max(task$data(cols = order_cols)[[1L]])
      # TODO: it's sufficient to store the max index + lags of the training data, like done in PipeOpFcstLags
      private$.task = task$clone()
      target = task$target_names
      dt = private$.lag_transform(task$data(), target)
      if (order_cols %nin% col_roles$feature) {
        dt[, (order_cols) := NULL]
      }
      new_task = as_task_regr(dt, target = target)
      learner = self$learner$clone(deep = TRUE)$train(new_task)
      structure(list(learner = learner), class = c("forecast_learner_model", "list"))
    },

    .predict = function(task) {
      private$.predict_recursive(task)
    },

    .predict_recursive = function(task) {
      if (length(task$col_roles$key) > 0L) {
        stopf("ForecastLearner does not yet support key columns for prediction.")
      }
      target = private$.task$target_names
      if (private$.is_newdata(task)) {
        row_ids = private$.task$nrow + seq_len(task$nrow)
        dt = rbind(private$.task$data(), task$data(), fill = TRUE)
      } else {
        row_ids = task$row_ids
        dt = private$.task$data()
      }

      # one model for all steps
      preds = map(row_ids, function(i) {
        new_x = private$.lag_transform(dt, target)[i]
        pred = self$model$learner$predict_newdata(new_x)
        set(dt, i = i, j = target, value = pred$response)
        pred
      })
      preds = do.call(c, preds)
      preds$data$row_ids = seq_along(row_ids)
      preds
    },

    .predict_direct = function(dt, n) {
      # one model for each step, would also need to adjust .train(),
      # might make more sense have a special class for each method
      .NotYetImplemented()
    },

    .lag_transform = function(dt, target) {
      lags = self$lags
      nms = sprintf("%s_lag_%i", target, lags)
      dt = copy(dt)
      col_roles = private$.task$col_roles
      order_cols = col_roles$order
      key_cols = col_roles$key
      # TODO: sorting here is overkill, remove once done
      if (length(key_cols) > 0L) {
        setorderv(dt, c(key_cols, order_cols))
        dt[, (nms) := shift(get(target), lags), by = key_cols]
      } else {
        setorderv(dt, order_cols)
        dt[, (nms) := shift(get(target), lags)]
      }
      dt
    },

    .is_newdata = function(task) {
      order_cols = task$col_roles$order
      dt = task$backend$data(rows = task$row_ids, cols = order_cols)
      if (nrow(dt) == 0L) {
        return(TRUE)
      }
      !any(private$.max_index %in% dt[[1L]])
    }
  )
)
