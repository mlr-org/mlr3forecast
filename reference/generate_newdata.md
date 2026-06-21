# Generate new data for a forecast task

Generate new data for a forecast task

## Usage

``` r
generate_newdata(task, n = 1L)
```

## Arguments

- task:

  [TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md)  
  Task.

- n:

  (`integer(1)`)  
  Number of new data points to generate. Default `1L`.

## Value

A
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
with `n` new data points.

## Details

Future dates are extrapolated with
[`base::seq()`](https://rdrr.io/r/base/seq.html), which has no month-end
awareness. For `Date`/`POSIXct` order columns with a calendar `freq`
(`month`/`quarter`/`year`), anchor the dates to a fixed day-of-month
(e.g. the first), since month-end series produce incorrect future dates.
