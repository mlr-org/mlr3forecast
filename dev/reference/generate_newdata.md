# Generate New Data for a Forecast Task

Extends each series by `n` time steps, retaining the order and key
columns and setting the target to `NA`.

## Usage

``` r
generate_newdata(task, n = 1L)
```

## Arguments

- task:

  ([TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md))  
  Task.

- n:

  (`integer(1)`)  
  Number of future observations per series. Default `1L`.

## Value

A
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
with `n` rows per series.

## Details

For monthly, quarterly, or yearly `freq`, the day of the month is
preserved where possible and clamped to the last valid day otherwise.
Series observed at month ends continue at month ends. Other frequencies
use [`base::seq()`](https://rdrr.io/r/base/seq.html).
