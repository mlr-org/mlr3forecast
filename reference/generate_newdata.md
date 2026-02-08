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
