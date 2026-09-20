#' @param period (`character()` | `numeric()` | `NULL`)\cr
#'   Seasonal period(s) of the time series, in observations per cycle.
#'   Either a positive number (or vector of them) such as `12`, or a cycle name resolved against
#'   `freq` such as `"year"` or `"week"`.
#'   The cycle names a calendar `freq` implies and the periods they resolve to are:
#'
#'   | `freq`      | `"hour"` | `"day"` | `"week"` | `"year"` |
#'   |-------------|----------|---------|----------|----------|
#'   | `"min"`     | 60       | 1440    | 10080    | 525960   |
#'   | `"hour"`    |          | 24      | 168      | 8766     |
#'   | `"day"`     |          |         | 7        | 365.25   |
#'   | `"week"`    |          |         |          | 52.18    |
#'   | `"month"`   |          |         |          | 12       |
#'   | `"quarter"` |          |         |          | 4        |
#'
#'   A multiple of a unit divides the period, e.g. `"30 min"` resolves `"day"` to `48`.
#'   If `NULL` (default), the period is derived from `freq` as the shortest implied cycle spanning at
#'   least four observations, e.g. `12` for monthly, `4` for quarterly, `7` for daily and `24` for
#'   hourly data.
#'   Sets the default for every learner, `PipeOp` and `Measure` that needs a seasonal period; each of
#'   them accepts its own `period` hyperparameter that takes precedence.
