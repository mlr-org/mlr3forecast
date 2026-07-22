# Generate new data for a forecast task

Generate new data for a forecast task

## Usage

``` r
generate_newdata(task, n = 1L)
```

## Arguments

- task:

  [TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md)  
  Task.

- n:

  (`integer(1)`)  
  Number of new data points to generate. Default `1L`.

## Value

A
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
with `n` new data points.

## Details

Future dates are extrapolated by stepping the order column. For calendar
`freq` (`month`/`quarter`/`year`), the origin's day-of-month is carried
forward and clamped to each target month's last valid day. Other freqs
use [`base::seq()`](https://rdrr.io/r/base/seq.html). Month-end is not
inferred, so use a first-of-month or period-style index for genuine
month-end series.
