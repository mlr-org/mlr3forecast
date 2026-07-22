#' @param freq (`character(1)` | `numeric(1)` | `NULL`)\cr
#'   Frequency of the time series.
#'   A `seq()`-compatible string gives the calendar step of the time grid, e.g.
#'   `"1 month"`, `"day"`, `"3 months"`, `"1 hour"`, `"week"`.
#'   A positive number gives the seasonal period (as in [stats::ts()]) for an integer or
#'   numeric order column; the grid step is then inferred from the data.
