#' Generate new data for a forecast task
#'
#' @details
#' Future dates are extrapolated by stepping the order column. For calendar `freq` (`month`/`quarter`/`year`), the
#' origin's day-of-month is carried forward and clamped to each target month's last valid day (e.g. Jan-31 steps to
#' Feb-28/29, Mar-31, ...). Other freqs use [base::seq()] directly. Month-end anchoring is not inferred: an Apr-30 or
#' Feb-28 origin stays on that day rather than snapping to each month's end, so use a first-of-month or period-style
#' index for genuine month-end series.
#'
#' @param task [TaskFcst]\cr
#'   Task.
#' @param n (`integer(1)`)\cr
#'   Number of new data points to generate. Default `1L`.
#' @return A [data.table::data.table()] with `n` new data points.
#' @export
generate_newdata = function(task, n = 1L) {
  task = assert_task(as_task(task), task_type = "fcst")
  n = assert_count(n, positive = TRUE, coerce = TRUE)

  col_roles = task$col_roles
  order_cols = col_roles$order
  key_cols = col_roles$key
  cols = c(order_cols, key_cols)
  dt = task$data(cols = cols)
  setorderv(dt, c(key_cols, order_cols))
  assert_regular_grid(dt, order_cols, key_cols, task$freq)

  last_rows = if (length(key_cols) > 0L) dt[, .SD[.N], by = key_cols] else dt[.N]
  freq = if (is.character(task$freq)) task$freq else infer_freq(sort(unique(dt[[order_cols]])))
  newdata = last_rows[rep(seq_len(.N), each = n)]

  if (length(key_cols) > 0L) {
    newdata[, (order_cols) := seq_order(get(order_cols)[1L], freq, n), by = key_cols]
  } else {
    set(newdata, j = order_cols, value = seq_order(last_rows[[order_cols]], freq, n))
  }

  set(newdata, j = task$target_names, value = NA_real_)
  newdata
}

#' @title Forecast from a Trained Learner
#'
#' @description
#' Generates `h` future rows from the task's skeleton (using [generate_newdata()]), optionally overlays user-supplied
#' `newdata` onto those rows, and predicts with the trained learner via [mlr3::Learner]`$predict_newdata()`. Works with
#' [RecursiveForecaster], [DirectForecaster], and classic `LearnerFcst*` forecasters.
#'
#' @param object ([mlr3::Learner])\cr
#'   A trained forecast learner.
#' @param task ([TaskFcst])\cr
#'   Provides the metadata needed to construct future rows: the order column (to extend the time index), key columns
#'   (for keyed tasks), `freq`, and the column-type schema expected by `predict_newdata()`. The task's data values are
#'   not used. Pass the training task or any other schema-compatible [TaskFcst].
#' @param h (`integer(1)`)\cr
#'   Forecast horizon — number of future time steps per key.
#' @param newdata ([data.frame()] | `NULL`)\cr
#'   Optional exogenous features for future rows. Must contain the order column (and any key
#'   columns for keyed tasks), and every row must match a row of the generated future grid.
#'   Columns other than those are overlaid onto the generated skeleton, while skeleton rows
#'   without a match keep `NA`.
#' @param ... (any)\cr
#'   Ignored.
#' @return [mlr3::Prediction].
#' @export
forecast.Learner = function(object, task, h = 12L, newdata = NULL, ...) {
  assert_learner(object)
  task = assert_task(as_task_fcst(task), task_type = "fcst")
  h = assert_count(h, positive = TRUE, coerce = TRUE)

  generated = generate_newdata(task, h)
  if (!is.null(newdata)) {
    newdata = as.data.table(newdata)
    by_cols = c(task$col_roles$order, task$col_roles$key)
    miss = setdiff(by_cols, names(newdata))
    if (length(miss) > 0L) {
      error_input(
        "`newdata` must contain the order column and any key columns of `task`, but is missing %s.",
        str_collapse(miss, quote = "'")
      )
    }
    if (anyDuplicated(newdata, by = by_cols) > 0L) {
      error_input("`newdata` contains duplicated %s combinations.", str_collapse(by_cols, quote = "'"))
    }
    n_unmatched = nrow(newdata[!generated, on = by_cols])
    if (n_unmatched > 0L) {
      error_input("%i row(s) of `newdata` do not match the generated future grid.", n_unmatched)
    }
    overlay_cols = setdiff(names(newdata), by_cols)
    if (length(overlay_cols) > 0L) {
      generated[newdata, on = by_cols, (overlay_cols) := mget(paste0("i.", overlay_cols))]
    }
  }
  object$predict_newdata(generated, task)
}
