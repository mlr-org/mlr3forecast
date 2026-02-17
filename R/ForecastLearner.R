#' @title Encapsulate a Learner as a Forecast Learner
#'
#' @description
#' The [ForecastLearner] wraps a [mlr3::Learner].
#'
#' @export
ForecastLearner = R6::R6Class(
  "ForecastLearner",
  inherit = Learner,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param learner ([mlr3::Learner])\cr
    #'   The regression learner to wrap.
    #' @param lags (`integer()`)\cr
    #'   The lag values to use for creating lag features.
    initialize = function(learner, lags) {
      private$.learner = assert_learner(as_learner(learner, clone = TRUE), task_type = "regr")
      private$.lags = assert_integerish(lags, lower = 1L, any.missing = FALSE, coerce = TRUE)

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
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function() {
      super$print()
      cat_cli(cli::cli_li("Lags: {self$lags}"))
    }
  ),

  active = list(
    #' @field learner ([mlr3::Learner])\cr
    #' The wrapped learner.
    learner = function(rhs) {
      assert_ro_binding(rhs)
      private$.learner
    },

    #' @field lags (`integer()`)\cr
    #' The lags to create.
    lags = function(rhs) {
      assert_ro_binding(rhs)
      private$.lags
    },

    #' @template field_param_set
    param_set = function(rhs) {
      param_set = self$learner$param_set
      if (!missing(rhs) && !identical(rhs, param_set)) {
        error_input("param_set is read-only.")
      }
      param_set
    }
  ),

  private = list(
    .learner = NULL,
    .lags = NULL,
    .history = NULL,

    .train = function(task) {
      if (max(self$lags) >= task$nrow) {
        error_input("Not enough data to create the required lags.")
      }

      col_roles = task$col_roles
      target = col_roles$target
      order_cols = col_roles$order
      key_cols = col_roles$key
      private$.history = task$view(ordered = TRUE)
      lagged = private$.lag_transform(private$.history, target, order_cols, key_cols)
      if (order_cols %nin% col_roles$feature) {
        set(lagged, j = order_cols, value = NULL)
      }
      new_task = as_task_regr(lagged, target = target)
      learner = self$learner$clone(deep = TRUE)$train(new_task)
      structure(list(learner = learner), class = c("forecast_learner_model", "list"))
    },

    .predict = function(task) {
      if (length(task$col_roles$key) > 0L) {
        private$.predict_global(task)
      } else {
        private$.predict_local(task)
      }
    },

    .predict_local = function(task) {
      target = task$target_names
      order_cols = task$col_roles$order
      newdata = task$view(ordered = TRUE)
      history = private$.history[!newdata, on = order_cols]
      window = tail(history, max(self$lags))

      preds = vector("list", nrow(newdata))
      for (i in seq_len(nrow(newdata))) {
        window = rbind(window, newdata[i])
        lagged = private$.lag_transform(window, target, order_cols)
        pred = self$model$learner$predict_newdata(lagged[.N])
        set(window, i = nrow(window), j = target, value = pred$response)
        window = window[-1L]
        preds[[i]] = pred
      }
      preds = do.call(c, preds)
      preds$data = insert_named(
        preds$data,
        list(row_ids = task$row_ids, extra = as.list(newdata[, order_cols, with = FALSE]))
      )
      preds
    },

    .predict_global = function(task) {
      target = task$target_names
      col_roles = task$col_roles
      order_cols = col_roles$order
      key_cols = col_roles$key
      history = private$.history
      max_lag = max(self$lags)

      preds = map(split(task$view(ordered = TRUE), by = key_cols, drop = TRUE), function(newdata) {
        key_history = history[newdata[1L, key_cols, with = FALSE], on = key_cols, nomatch = NULL]
        key_history = key_history[!newdata, on = order_cols]
        window = tail(key_history, max_lag)

        preds = vector("list", nrow(newdata))
        for (i in seq_len(nrow(newdata))) {
          window = rbind(window, newdata[i])
          lagged = private$.lag_transform(window, target, order_cols, key_cols)
          pred = self$model$learner$predict_newdata(lagged[.N])
          set(window, i = nrow(window), j = target, value = pred$response)
          window = window[-1L]
          preds[[i]] = pred
        }
        do.call(c, preds)
      })
      preds = do.call(c, preds)
      preds$data = insert_named(
        preds$data,
        list(row_ids = task$row_ids, extra = as.list(task$data(cols = c(key_cols, order_cols))))
      )
      preds
    },

    .lag_transform = function(dt, target, order_cols, key_cols = NULL) {
      lags = self$lags
      lag_cols = sprintf("%s_lag_%i", target, lags)
      dt = copy(dt)
      if (length(key_cols) > 0L) {
        setorderv(dt, c(key_cols, order_cols))
        dt[, (lag_cols) := shift(get(target), lags), by = key_cols]
      } else {
        setorderv(dt, order_cols)
        dt[, (lag_cols) := shift(get(target), lags)]
      }
      dt
    }
  )
)

#' @title Convert to a Forecast Learner
#'
#' @param learner ([mlr3::Learner])\cr
#'   The regression learner to wrap.
#' @param lags (`integer()`)\cr
#'   The lag values to use for creating lag features.
#' @return [ForecastLearner].
#' @export
as_learner_fcst = function(learner, lags) {
  ForecastLearner$new(learner, lags)
}
