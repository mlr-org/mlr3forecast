#' @title Abstract class for setartree package learners
#' @keywords internal
#' @include LearnerFcst.R
LearnerFcstSetar = R6Class(
  "LearnerFcstSetar",
  inherit = LearnerFcst,
  private = list(
    .fn = NULL,

    # a keyed task is fitted as one global model across all series, an unkeyed task as a single series
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      target = task$target_names
      key_cols = task$col_roles$key
      order_cols = task$col_roles$order

      dt = task$data(cols = c(key_cols, order_cols, target))
      setorderv(dt, c(key_cols, order_cols))
      series = dt[,
        list(.y = list(as.numeric(get(target))), .origin = max(get(order_cols))),
        by = key_cols
      ]

      lag = pv$lag %??% 10L
      short = lengths(series$.y) <= lag
      if (any(short)) {
        msg = sprintf("%s needs more than `lag = %i` observations per series", self$id, lag)
        if (length(key_cols) > 0L) {
          error_input(
            "%s, but key group(s) %s are too short.",
            msg,
            str_collapse(key_labels(series[short], key_cols), quote = "'")
          )
        }
        error_input("%s.", msg)
      }

      list(
        model = private$.fit(series$.y, pv),
        # forecast() starts from the end of the passed series, so keep the training history
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
        set(dt, j = ".series", value = rep_len(1L, nrow(dt)))
      }
      set(dt, j = ".origin", value = keys$.origin[dt$.series])
      if (any(dt[[order_cols]] <= dt$.origin)) {
        error_config("In-sample prediction is not supported for %s.", self$id)
      }

      # step position of each row after the end of its series, the rows of a series must be its next steps
      step = self$model$step
      dt[, ".pos" := match(get(order_cols), seq_order(get(".origin")[1L], step, .N)), by = ".series"]
      bad = is.na(dt$.pos) | duplicated(dt[, c(".series", ".pos"), with = FALSE])
      if (any(bad)) {
        msg = "Future rows must form the gap-free future grid following the training data"
        if (length(key_cols) > 0L) {
          error_input(
            "%s. Offending key group(s): %s.",
            msg,
            str_collapse(key_labels(unique(dt[bad, key_cols, with = FALSE]), key_cols), quote = "'")
          )
        }
        error_input("%s (last training index: %s).", msg, format(keys$.origin))
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

      # forecasts are stacked series by series, h steps each
      rows = (match(dt$.series, series) - 1L) * h + dt$.pos
      response = unlist(map(fcsts, function(x) as.numeric(x$mean)), use.names = FALSE)[rows]
      if (!is_quantile) {
        return(insert_named(prediction, list(response = response)))
      }

      stack_bounds = function(bound) {
        do.call(rbind, map(fcsts, function(x) as.matrix(x[[bound]])))[rows, , drop = FALSE]
      }
      pred = list(mean = response, lower = stack_bounds("lower"), upper = stack_bounds("upper"))
      insert_named(prediction, list(quantiles = private$.quantiles_from_intervals(pred)))
    }
  )
)
