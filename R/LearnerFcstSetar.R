#' @title Abstract class for setartree package learners
#' @keywords internal
#' @include LearnerFcst.R
LearnerFcstSetar = R6Class(
  "LearnerFcstSetar",
  inherit = LearnerFcst,
  private = list(
    .fn = NULL,

    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      target = task$target_names
      key_cols = task$col_roles$key
      order_cols = task$col_roles$order

      dt = task$data(cols = c(key_cols, order_cols, target))
      setorderv(dt, c(key_cols, order_cols))
      series = dt[, list(.y = list(as.numeric(get(target))), .origin = max(get(order_cols))), by = key_cols]

      lag = pv$lag %??% 10L
      if (any(lengths(series$.y) <= lag)) {
        error_input("%s needs more than `lag = %i` observations per series.", self$id, lag)
      }

      list(
        model = private$.fit(series$.y, pv),
        y = series$.y,
        keys = series[, c(key_cols, ".origin"), with = FALSE],
        key_cols = key_cols,
        step = resolve_step(task$freq, dt[[order_cols]], dt[, key_cols, with = FALSE])
      )
    },

    .fit = function(y, pv) {
      fn = getExportedValue("setartree", private$.fn)
      invoke(fn, data = y, .args = pv)
    },

    .predict = function(task) {
      is_quantile = self$predict_type == "quantiles"
      if (is_quantile) {
        assert_quantiles(self, quantile_response = TRUE)
      }
      key_cols = self$model$key_cols
      order_cols = task$col_roles$order
      keys = self$model$keys

      dt = task$data(cols = c(key_cols, order_cols))
      prediction = list(extra = as.list(dt))

      if (length(key_cols) > 0L) {
        assert_seen_keys(keys, dt, key_cols)
        set(dt, j = ".series", value = keys[dt, on = key_cols, which = TRUE])
      } else {
        set(dt, j = ".series", value = 1L)
      }
      set(dt, j = ".origin", value = keys$.origin[dt$.series])
      if (any(dt[[order_cols]] <= dt$.origin)) {
        error_config("In-sample prediction is not supported for %s.", self$id)
      }

      dt[, ".pos" := match(get(order_cols), seq_order(get(".origin")[1L], self$model$step, .N)), by = ".series"]
      if (anyNA(dt$.pos) || anyDuplicated(dt, by = c(".series", ".pos"))) {
        error_input("Future rows must form the gap-free future grid following the training data.")
      }

      series = sort(unique(dt$.series))
      h = max(dt$.pos)
      args = list(newdata = self$model$y[series], h = h)
      if (is_quantile) {
        level = quantiles_to_levels(private$.quantiles)
        if (length(level) > 0L) {
          # pass fractions, since setartree rescales levels that are all below 1
          args$level = level / 100
        }
      }
      fcsts = invoke(generics::forecast, self$native_model, .args = args)$forecast

      # stack the forecasts series by series, h steps each, and pick each row's series and step
      rows = (match(dt$.series, series) - 1L) * h + dt$.pos
      pred = map(set_names(c("mean", "lower", "upper")), function(field) {
        map_br(fcsts, function(x) as.matrix(x[[field]]))[rows, , drop = FALSE]
      })
      if (!is_quantile) {
        return(insert_named(prediction, list(response = as.numeric(pred$mean))))
      }

      insert_named(prediction, list(quantiles = private$.quantiles_from_intervals(pred)))
    }
  )
)
