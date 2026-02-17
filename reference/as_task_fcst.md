# Convert to a Forecast Task

Convert object to a
[TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md). This
is a S3 generic. mlr3forecast ships with methods for the following
objects:

1.  [TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md):
    ensure the identity

2.  [`data.frame()`](https://rdrr.io/r/base/data.frame.html) and
    [mlr3::DataBackend](https://mlr3.mlr-org.com/reference/DataBackend.html):
    provides an alternative to the constructor of
    [TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md).

3.  `ts`: from base R time series objects (univariate and multivariate).

4.  `zoo` and `xts`: from zoo/xts time series objects.

5.  `tsf`: from tsf format data.

6.  `tbl_ts`: from tsibble objects.

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
  Name of the key column.

- freq:

  (`character(1)` \| `numeric(1)` \| `NULL`)  
  Frequency of the time series. Either a positive number or a
  [`seq()`](https://rdrr.io/r/base/seq.html)-compatible string, e.g.:
  `"1 month"`, `"day"`, `"3 months"`, `"1 hour"`, `"week"`.

- id:

  (`character(1)`)  
  Id for the new task. Defaults to the (deparsed and substituted) name
  of the data argument.

- label:

  (`character(1)`)  
  Label for the new instance.

## Value

[TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md).

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
