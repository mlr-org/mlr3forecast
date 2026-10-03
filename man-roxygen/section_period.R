#' @section Seasonal period:
#' The seasonal period is not stored in the task.
#' It is set by the `period` hyperparameter, in observations per cycle.
#' Either a positive number such as `12`, or a cycle name resolved against the task's `freq` such as `"year"` or
#' `"week"`.
#' The cycle names a calendar `freq` implies and the periods they resolve to are:
#'
#' | `freq`      | `"hour"` | `"day"` | `"week"` | `"year"` |
#' |-------------|----------|---------|----------|----------|
#' | `"min"`     | 60       | 1440    | 10080    | 525960   |
#' | `"hour"`    |          | 24      | 168      | 8766     |
#' | `"day"`     |          |         | 7        | 365.25   |
#' | `"week"`    |          |         |          | 52.18    |
#' | `"month"`   |          |         |          | 12       |
#' | `"quarter"` |          |         |          | 4        |
#'
#' A multiple of a unit divides the period, e.g. `"30 min"` resolves `"day"` to `48`.
#' If `period` is `NULL` (default), it is the day for sub-daily data (the hour below a minute), the week for daily
#' data, and the year for longer steps, skipping a cycle of fewer than four observations for the next longer one.
#' This gives e.g. `12` for monthly, `4` for quarterly, `7` for daily, `24` for hourly, and `48` for half-hourly data.
#' Without a calendar `freq`, the default is `1`, i.e. no seasonality.
