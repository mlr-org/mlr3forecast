#' @param freq (`character(1)` | `numeric(1)` | `NULL`)\cr
#'   Step of the time index, i.e. the spacing between two consecutive observations.
#'   A `seq()`-compatible string for a `Date` or `POSIXct` order column, e.g.
#'   `"1 month"`, `"day"`, `"3 months"`, `"1 hour"`, `"week"`,
#'   and a positive number for a numeric or integer order column.
#'   A given `freq` must match the order column, i.e. every observation must be a whole number of steps after the
#'   first observation of its series, gaps allowed, and at least two consecutive observations of a series must be one
#'   step apart.
#'   If `NULL` (default), the step is inferred on construction and must be the same for all series.
#'   For a numeric or integer order column, it is the greatest common divisor of the gaps of whole-number values,
#'   else the median gap, and `1` if no series has two observations.
#'   For a `Date` or `POSIXct` order column, it is inferred from the typical gap, e.g. `"1 month"` for monthly or
#'   month-end data and `"1 DSTday"` for daily local clock times in a time zone with daylight saving time.
#'   An error is raised if the step cannot be inferred, i.e. for series with different steps, observations off the
#'   inferred grid, or a `Date` or `POSIXct` order column without a series of two observations.
#'   This is *not* the seasonal period, which learners, measures, and pipeops take as their `period` hyperparameter.
