#' @title Generate New Data for a Forecast Task
#'
#' @description
#' Extends each series by `n` time steps, retaining the order and key columns and setting the target to `NA`.
#'
#' @details
#' For monthly, quarterly, or yearly `freq`, the day of the month is preserved where possible
#' and clamped to the last valid day otherwise.
#' Series observed at month ends continue at month ends.
#' Other frequencies use [base::seq()].
#'
#' @param task ([TaskFcst])\cr
#'   Task.
#' @param n (`integer(1)`)\cr
#'   Number of future observations per series.
#'   Default `1L`.
#' @return A [data.table::data.table()] with `n` rows per series.
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
  freq = task$freq
  assert_regular_grid(dt, order_cols, key_cols, freq)

  newdata = dt[,
    list(order_cols = extend_order(order_cols, freq, n)),
    by = key_cols,
    env = list(order_cols = order_cols, freq = I(freq), n = n, key_cols = I(key_cols))
  ]
  setcolorder(newdata, cols)
  set(newdata, j = task$target_names, value = NA_real_)
  newdata
}

#' @title Forecast from a Trained Learner
#'
#' @description
#' Generates `h` future observations per series with [generate_newdata()] and predicts with a trained learner.
#' Optional `newdata` supplies future feature values.
#'
#' @param object ([mlr3::Learner])\cr
#'   A trained forecast learner.
#' @param task ([TaskFcst])\cr
#'   Task whose last observation in each series defines the forecast origin.
#'   Its order column, keys, and `freq` define the future time grid.
#'   Its column types must match those expected by the trained learner.
#' @param h (`integer(1)`)\cr
#'   Number of future time steps per series.
#' @param newdata ([data.frame()] | `NULL`)\cr
#'   Optional exogenous features for future rows.
#'   Must contain the order column (and any key
#'   columns for keyed tasks), and every row must match a row of the generated future grid.
#'   Columns other than those are overlaid onto the generated skeleton, while skeleton rows
#'   without a match keep `NA`.
#'   Required if `task` has features, and must then contain every feature column.
#' @param ... (any)\cr
#'   Must be empty.
#' @return [mlr3::Prediction].
#' @export
forecast.Learner = function(object, task, h = 12L, newdata = NULL, ...) {
  assert_empty_ellipsis(...)
  assert_learner(object)
  task = assert_task(as_task_fcst(task), task_type = "fcst")
  h = assert_count(h, positive = TRUE, coerce = TRUE)

  generated = generate_newdata(task, h)
  if (!is.null(newdata)) {
    assert_data_frame(newdata, col.names = "unique")
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
      generated[
        newdata,
        on = by_cols,
        (overlay_cols) := mget(paste0("i.", overlay_cols)),
        env = list(overlay_cols = I(overlay_cols))
      ]
    }
  }
  miss = setdiff(task$feature_names, names(generated))
  if (length(miss) > 0L) {
    error_input("`newdata` must supply the future values of the feature(s) %s.", str_collapse(miss, quote = "'"))
  }
  object$predict_newdata(generated, task)
}
