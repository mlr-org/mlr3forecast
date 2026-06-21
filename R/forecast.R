#' Generate new data for a forecast task
#'
#' @param task [TaskFcst]\cr
#'   Task.
#' @param n (`integer(1)`)\cr
#'   Number of new data points to generate. Default `1L`.
#' @return A [data.table::data.table()] with `n` new data points.
#' @details
#' Future dates are extrapolated with [base::seq()], which has no month-end awareness. For
#' `Date`/`POSIXct` order columns with a calendar `freq` (`month`/`quarter`/`year`), anchor the
#' dates to a fixed day-of-month (e.g. the first), since month-end series produce incorrect future
#' dates.
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

  last_rows = if (length(key_cols) > 0L) dt[, .SD[.N], by = key_cols] else dt[.N]

  freq = task$freq %??% infer_freq(sort(unique(dt[[order_cols]])))
  newdata = last_rows[rep(seq_len(.N), each = n)]
  if (length(key_cols) > 0L) {
    newdata[, (order_cols) := seq(get(order_cols)[1L], length.out = n + 1L, by = freq)[-1L], by = key_cols]
  } else {
    set(newdata, j = order_cols, value = seq(last_rows[[order_cols]], length.out = n + 1L, by = freq)[-1L])
  }

  set(newdata, j = task$target_names, value = NA_real_)
  newdata
}

#' @title Forecast from a Trained Learner
#'
#' @description
#' Generates `h` future rows from the task's skeleton (using [generate_newdata()]), optionally
#' overlays user-supplied `newdata` onto those rows, and predicts with the trained learner via
#' [mlr3::Learner]`$predict_newdata()`. Works with [RecursiveForecaster], [DirectForecaster],
#' and classic `LearnerFcst*` forecasters.
#'
#' @param object ([mlr3::Learner])\cr
#'   A trained forecast learner.
#' @param task ([TaskFcst])\cr
#'   Provides the metadata needed to construct future rows: the order column (to extend the time
#'   index), key columns (for keyed tasks), `freq`, and the column-type schema expected by
#'   `predict_newdata()`. The task's data values are not used. Pass the training task or any other
#'   schema-compatible [TaskFcst].
#' @param h (`integer(1)`)\cr
#'   Forecast horizon — number of future time steps per key.
#' @param newdata ([data.frame()] | `NULL`)\cr
#'   Optional exogenous features for future rows. Must contain the order column (and any key
#'   columns for keyed tasks). Columns other than those are overlaid onto the generated skeleton.
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
    by_cols = intersect(c(task$col_roles$order, task$col_roles$key), names(newdata))
    if (length(by_cols) == 0L) {
      error_input("`newdata` must contain the order column and any key columns of `task`.")
    }
    overlay_cols = setdiff(names(newdata), by_cols)
    if (length(overlay_cols) > 0L) {
      generated[newdata, on = by_cols, (overlay_cols) := mget(paste0("i.", overlay_cols))]
    }
  }
  object$predict_newdata(generated, task)
}
