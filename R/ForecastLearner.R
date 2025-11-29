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
      target = col_roles$target
      order_cols = col_roles$order
      private$.max_index = max(task$data(cols = order_cols)[[1L]])
      private$.task = task$clone()
      lagged = private$.lag_transform(task$data(include_order = TRUE), target)
      if (order_cols %nin% col_roles$feature) {
        set(lagged, j = order_cols, value = NULL)
      }
      new_task = as_task_regr(lagged, target = target)
      learner = self$learner$clone(deep = TRUE)$train(new_task)
      structure(list(learner = learner), class = c("forecast_learner_model", "list"))
    },

    .predict = function(task) {
      if (length(task$col_roles$key) > 0L) {
        preds = private$.predict_global(task)
      } else {
        preds = private$.predict_local(task)
      }
      assert_true(length(preds$data$row_ids) == task$nrow)
      preds
    },

    .predict_local = function(task) {
      target = task$target_names
      order_cols = task$col_roles$order
      history = private$.task$data(include_order = TRUE)
      dt = task$data(include_order = TRUE)
      history = if (private$.is_newdata(task)) history else history[!dt, on = order_cols]

      preds = vector("list", nrow(dt))
      for (i in seq_len(nrow(dt))) {
        history = rbind(history, dt[i])
        lagged = private$.lag_transform(history, target)
        pred = self$model$learner$predict_newdata(lagged[.N])
        set(history, i = nrow(history), j = target, value = pred$response)
        preds[[i]] = pred
      }
      preds = do.call(c, preds)
      preds$data$row_ids = task$row_ids
      preds
    },

    .predict_global = function(task) {
      target = task$target_names
      col_roles = task$col_roles
      order_cols = col_roles$order
      key_cols = col_roles$key
      is_newdata = private$.is_newdata(task)
      history = private$.task$data(include_order = TRUE)

      preds = map(split(task$data(include_order = TRUE), by = key_cols, drop = TRUE), function(dt) {
        history = history[dt[1L, key_cols, with = FALSE], on = key_cols, nomatch = NULL]
        history = if (is_newdata) history else history[!dt, on = order_cols]

        preds = vector("list", nrow(dt))
        for (i in seq_len(nrow(dt))) {
          history = rbind(history, dt[i])
          lagged = private$.lag_transform(history, target)
          pred = self$model$learner$predict_newdata(lagged[.N])
          set(history, i = nrow(history), j = target, value = pred$response)
          preds[[i]] = pred
        }
        do.call(c, preds)
      })
      preds = do.call(c, preds)
      preds$data$row_ids = task$row_ids
      preds
    },

    .lag_transform = function(dt, target) {
      lags = self$lags
      nms = sprintf("%s_lag_%i", target, lags)
      col_roles = private$.task$col_roles
      order_cols = col_roles$order
      key_cols = col_roles$key
      # TODO: sorting here is overkill, remove once done
      dt = copy(dt)
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
      dt = task$backend$data(rows = task$row_ids, cols = task$col_roles$order)
      if (nrow(dt) == 0L) {
        return(TRUE)
      }
      !any(private$.max_index %in% dt[[1L]])
    }
  )
)
