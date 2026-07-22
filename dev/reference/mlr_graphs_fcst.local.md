# Create a Graph to Fit Local Per-Series Forecast Models

Create a new
[Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html) that
wraps `graph` between
[`po("fcst.splitkey")`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.splitkey.md)
and
[`po("fcst.unitekey")`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.unitekey.md),
fitting one local model per series of a keyed
[TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md)
instead of one global model pooled across series.

All input arguments are cloned and have no references in common with the
returned
[Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html).

## Usage

``` r
pipeline_fcst_local(graph, key = "key")
```

## Arguments

- graph:

  ([Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html))  
  Graph being wrapped between
  [`po("fcst.splitkey")`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.splitkey.md)
  and
  [`po("fcst.unitekey")`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.unitekey.md).
  The graph should return `NULL` during training and a
  [PredictionFcst](https://mlr3forecast.mlr-org.com/dev/reference/PredictionFcst.md)
  during prediction.

- key:

  (`character(1)`)  
  Name of the rebuilt series-identity column in the united prediction's
  `extra` slot, default `"key"`. Set it to the task's key column name to
  get predictions column-compatible with global forecasters such as
  [RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md).

## Value

[Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)

## Examples

``` r
library(mlr3pipelines)
library(data.table)
dt = CJ(
  month = seq(as.Date("2024-01-01"), by = "month", length.out = 36L),
  id = factor(c("a", "b"))
)
dt[, value := rnorm(.N, mean = fifelse(id == "a", 10, 20))]
#> Key: <month, id>
#>          month     id     value
#>         <Date> <fctr>     <num>
#>  1: 2024-01-01      a  8.599956
#>  2: 2024-01-01      b 20.255317
#>  3: 2024-02-01      a  7.562736
#>  4: 2024-02-01      b 19.994429
#>  5: 2024-03-01      a 10.621553
#>  6: 2024-03-01      b 21.148412
#>  7: 2024-04-01      a  8.178182
#>  8: 2024-04-01      b 19.752675
#>  9: 2024-05-01      a  9.755800
#> 10: 2024-05-01      b 19.717295
#> 11: 2024-06-01      a  9.446301
#> 12: 2024-06-01      b 20.628982
#> 13: 2024-07-01      a 12.065025
#> 14: 2024-07-01      b 18.369011
#> 15: 2024-08-01      a 10.512427
#> 16: 2024-08-01      b 18.136989
#> 17: 2024-09-01      a  9.477987
#> 18: 2024-09-01      b 19.947398
#> 19: 2024-10-01      a 10.542996
#> 20: 2024-10-01      b 19.085925
#> 21: 2024-11-01      a 10.468154
#> 22: 2024-11-01      b 20.362951
#> 23: 2024-12-01      a  8.695456
#> 24: 2024-12-01      b 20.737776
#> 25: 2025-01-01      a 11.888505
#> 26: 2025-01-01      b 19.902555
#> 27: 2025-02-01      a  9.064153
#> 28: 2025-02-01      b 19.984050
#> 29: 2025-03-01      a  9.173211
#> 30: 2025-03-01      b 18.487600
#> 31: 2025-04-01      a 10.935363
#> 32: 2025-04-01      b 20.176489
#> 33: 2025-05-01      a 10.243685
#> 34: 2025-05-01      b 21.623549
#> 35: 2025-06-01      a 10.112038
#> 36: 2025-06-01      b 19.866003
#> 37: 2025-07-01      a  8.089913
#> 38: 2025-07-01      b 19.720763
#> 39: 2025-08-01      a  9.686554
#> 40: 2025-08-01      b 21.067308
#> 41: 2025-09-01      a 10.070035
#> 42: 2025-09-01      b 19.360877
#> 43: 2025-10-01      a  9.950035
#> 44: 2025-10-01      b 19.748517
#> 45: 2025-11-01      a 10.444797
#> 46: 2025-11-01      b 22.755418
#> 47: 2025-12-01      a 10.046531
#> 48: 2025-12-01      b 20.577709
#> 49: 2026-01-01      a 10.118195
#> 50: 2026-01-01      b 18.088280
#> 51: 2026-02-01      a 10.862086
#> 52: 2026-02-01      b 19.756763
#> 53: 2026-03-01      a  9.793913
#> 54: 2026-03-01      b 20.019178
#> 55: 2026-04-01      a 10.029561
#> 56: 2026-04-01      b 20.549828
#> 57: 2026-05-01      a  7.725885
#> 58: 2026-05-01      b 22.682557
#> 59: 2026-06-01      a  9.638779
#> 60: 2026-06-01      b 20.213356
#> 61: 2026-07-01      a 11.074346
#> 62: 2026-07-01      b 19.334912
#> 63: 2026-08-01      a 11.113952
#> 64: 2026-08-01      b 19.754104
#> 65: 2026-09-01      a  8.822437
#> 66: 2026-09-01      b 19.024149
#> 67: 2026-10-01      a 11.065057
#> 68: 2026-10-01      b 20.131671
#> 69: 2026-11-01      a 10.488629
#> 70: 2026-11-01      b 18.300549
#> 71: 2026-12-01      a  8.529264
#> 72: 2026-12-01      b 20.284150
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
flrn = as_learner(ppl("fcst.local", lrn("fcst.ets")))$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.856516
#>    a 2027-02-01       2    NA  9.856516
#>    a 2027-03-01       3    NA  9.856516
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 19.987351
#>    b 2027-11-01      23    NA 19.987351
#>    b 2027-12-01      24    NA 19.987351
```
