#' @param freq (`character(1)` | `NULL`)\cr
#'   Step of the time index, i.e. the spacing between two consecutive observations.
#'   A `seq()`-compatible string for a `Date` or `POSIXct` order column, e.g.
#'   `"1 month"`, `"day"`, `"3 months"`, `"1 hour"`, `"week"`.
#'   If `NULL` (default), the step is inferred from the order column, which is required for a numeric or integer
#'   order column.
#'   This is *not* the seasonal period, which learners, measures, and pipeops take as their `period` hyperparameter.
