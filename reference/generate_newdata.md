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

Future dates are extrapolated by stepping the order column. For calendar
`freq` (`month`/`quarter`/`year`), the origin's day-of-month is carried
forward and clamped to each target month's last valid day (e.g. Jan-31
steps to Feb-28/29, Mar-31, ...); other freqs use
[`base::seq()`](https://rdrr.io/r/base/seq.html) directly. Month-end
anchoring is not inferred: an Apr-30 or Feb-28 origin stays on that day
rather than snapping to each month's end, so use a first-of-month or
period-style index for genuine month-end series.
