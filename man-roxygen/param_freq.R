#' @param freq (`character(1)` | `numeric(1)` | `NULL`)\cr
#'   Step of the time index, i.e. the spacing between two consecutive observations.
#'   A `seq()`-compatible string for a `Date` or `POSIXct` order column, e.g.
#'   `"1 month"`, `"day"`, `"3 months"`, `"1 hour"`, `"week"`.
#'   A positive number for a numeric or integer order column.
#'   If `NULL` (default), the step is inferred from the order column.
#'   This is *not* the seasonal period -- see `period`.
