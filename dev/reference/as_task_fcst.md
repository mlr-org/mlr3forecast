# Convert to a Forecast Task

Convert object to a
[TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md).
This is a S3 generic. mlr3forecast ships with methods for the following
objects:

1.  [TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md):
    ensure the identity

2.  [`data.frame()`](https://rdrr.io/r/base/data.frame.html) and
    [mlr3::DataBackend](https://mlr3.mlr-org.com/reference/DataBackend.html):
    provides an alternative to the constructor of
    [TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md).

3.  `ts`: from base R time series objects (univariate and multivariate).
    A frequency of 1, 4, 12, 52, or 365.25 is taken as a yearly,
    quarterly, monthly, weekly, or daily step. Any other frequency has
    no calendar step, so the series gets an integer `index` column as
    order instead.

4.  `zoo` and `xts`: from zoo/xts time series objects.

5.  `timeSeries`: from Rmetrics timeSeries objects.

6.  `tsf`: from tsf format data.

7.  `tbl_ts`: from tsibble objects. The index becomes the order column,
    where `yearweek`, `yearmonth`, and `yearquarter` indices are
    converted to dates. If `freq` is `NULL`, such an index sets it from
    the tsibble's interval, e.g. `"1 month"` for a monthly `yearmonth`
    index, while other indices infer it like
    [TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md).
    The key variables become key columns, and all measured variables
    other than `target` become features.

## Usage

``` r
as_task_fcst(x, ...)

as_tasks_fcst(x, ...)

# Default S3 method
as_tasks_fcst(x, ...)

# S3 method for class 'list'
as_tasks_fcst(x, ...)

# S3 method for class 'TaskFcst'
as_task_fcst(x, clone = FALSE, ...)

# S3 method for class 'DataBackend'
as_task_fcst(
  x,
  target,
  order,
  key = character(),
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
)

# S3 method for class 'data.frame'
as_task_fcst(
  x,
  target,
  order,
  key = character(),
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
)

# S3 method for class 'tsf'
as_task_fcst(x, id = deparse1(substitute(x)), label = NA_character_, ...)

# S3 method for class 'tsf'
as_task(x, id = deparse1(substitute(x)), clone = FALSE, ...)

# S3 method for class 'ts'
as_task_fcst(
  x,
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
)

# S3 method for class 'zoo'
as_task_fcst(
  x,
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
)

# S3 method for class 'timeSeries'
as_task_fcst(
  x,
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
)

# S3 method for class 'tbl_ts'
as_task_fcst(
  x,
  target,
  freq = NULL,
  id = deparse1(substitute(x)),
  label = NA_character_,
  ...
)
```

## Arguments

- x:

  (any)  
  Object to convert.

- ...:

  (any)  
  Additional arguments.

- clone:

  (`logical(1)`)  
  If `TRUE`, ensures that the returned object is not the same as the
  input `x`.

- target:

  (`character(1)`)  
  Name of the target column.

- order:

  (`character(1)`)  
  Name of the order column.

- key:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Names of the columns whose combination identifies a series. Key
  columns must be character, integer, factor, or ordered columns.

- freq:

  (`character(1)` \| `numeric(1)` \| `NULL`)  
  Step of the time index, i.e. the spacing between two consecutive
  observations. A [`seq()`](https://rdrr.io/r/base/seq.html)-compatible
  string for a `Date` or `POSIXct` order column, e.g. `"1 month"`,
  `"day"`, `"3 months"`, `"1 hour"`, `"week"`, and a positive number for
  a numeric or integer order column. A given `freq` must match the order
  column, i.e. every observation must be a whole number of steps after
  the first observation of its series, gaps allowed, and at least two
  consecutive observations of a series must be one step apart. If `NULL`
  (default), the step is inferred on construction and must be the same
  for all series. For a numeric or integer order column, it is the
  greatest common divisor of the gaps of whole-number values, else the
  median gap, and `1` if no series has two observations. For a `Date` or
  `POSIXct` order column, it is inferred from the typical gap, e.g.
  `"1 month"` for monthly or month-end data and `"1 DSTday"` for daily
  local clock times in a time zone with daylight saving time. An error
  is raised if the step cannot be inferred, i.e. for series with
  different steps, observations off the inferred grid, or a `Date` or
  `POSIXct` order column without a series of two observations. This is
  *not* the seasonal period, which learners, measures, and pipeops take
  as their `period` hyperparameter.

- id:

  (`character(1)`)  
  Id for the new task. Defaults to the (deparsed and substituted) name
  of the data argument.

- label:

  (`character(1)`)  
  Label for the new instance.

## Value

[TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md).

## Examples

``` r
library(data.table)
airpassengers = tsbox::ts_dt(AirPassengers)
setnames(airpassengers, c("month", "passengers"))
as_task_fcst(airpassengers, target = "passengers", order = "month", freq = "month")
#> 
#> ── <TaskFcst> (144x1) ──────────────────────────────────────────────────────────
#> • Target: passengers
#> • Properties: ordered
#> • Order by: month
#> • Frequency: month
```
