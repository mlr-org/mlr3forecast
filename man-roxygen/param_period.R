#' @param period (`character()` | `numeric()` | `NULL`)\cr
#'   Seasonal period(s) of the time series, in observations per cycle.
#'   Either a positive number (or vector of them) such as `12`, or a cycle name resolved against
#'   `freq` such as `"year"` or `"week"`. See [common_periods()] for the cycles a frequency implies.
#'   If `NULL` (default), the period is derived from `freq`: the shortest implied cycle spanning at
#'   least four observations, e.g. `12` for monthly, `4` for quarterly, `7` for daily and `24` for
#'   hourly data.
#'   Sets the default for every learner, `PipeOp` and `Measure` that needs a seasonal period; each of
#'   them accepts its own `period` hyperparameter that takes precedence.
