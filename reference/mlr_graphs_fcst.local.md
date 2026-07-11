# Create a Graph to Fit Local Per-Series Forecast Models

Create a new
[Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html) that
wraps `graph` between
[`po("fcst.splitkey")`](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.splitkey.md)
and
[`po("fcst.unitekey")`](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.unitekey.md),
fitting one local model per series of a keyed
[TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md)
instead of one global model pooled across series.

All input arguments are cloned and have no references in common with the
returned
[Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html).

## Usage

``` r
pipeline_fcst_local(graph)
```

## Arguments

- graph:

  ([Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html))  
  Graph being wrapped between
  [`po("fcst.splitkey")`](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.splitkey.md)
  and
  [`po("fcst.unitekey")`](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.unitekey.md).
  The graph should return `NULL` during training and a
  [PredictionFcst](https://mlr3forecast.mlr-org.com/reference/PredictionFcst.md)
  during prediction.

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
#>  1: 2024-01-01      a 10.255317
#>  2: 2024-01-01      b 17.562736
#>  3: 2024-02-01      a  9.994429
#>  4: 2024-02-01      b 20.621553
#>  5: 2024-03-01      a 11.148412
#>  6: 2024-03-01      b 18.178182
#>  7: 2024-04-01      a  9.752675
#>  8: 2024-04-01      b 19.755800
#>  9: 2024-05-01      a  9.717295
#> 10: 2024-05-01      b 19.446301
#> 11: 2024-06-01      a 10.628982
#> 12: 2024-06-01      b 22.065025
#> 13: 2024-07-01      a  8.369011
#> 14: 2024-07-01      b 20.512427
#> 15: 2024-08-01      a  8.136989
#> 16: 2024-08-01      b 19.477987
#> 17: 2024-09-01      a  9.947398
#> 18: 2024-09-01      b 20.542996
#> 19: 2024-10-01      a  9.085925
#> 20: 2024-10-01      b 20.468154
#> 21: 2024-11-01      a 10.362951
#> 22: 2024-11-01      b 18.695456
#> 23: 2024-12-01      a 10.737776
#> 24: 2024-12-01      b 21.888505
#> 25: 2025-01-01      a  9.902555
#> 26: 2025-01-01      b 19.064153
#> 27: 2025-02-01      a  9.984050
#> 28: 2025-02-01      b 19.173211
#> 29: 2025-03-01      a  8.487600
#> 30: 2025-03-01      b 20.935363
#> 31: 2025-04-01      a 10.176489
#> 32: 2025-04-01      b 20.243685
#> 33: 2025-05-01      a 11.623549
#> 34: 2025-05-01      b 20.112038
#> 35: 2025-06-01      a  9.866003
#> 36: 2025-06-01      b 18.089913
#> 37: 2025-07-01      a  9.720763
#> 38: 2025-07-01      b 19.686554
#> 39: 2025-08-01      a 11.067308
#> 40: 2025-08-01      b 20.070035
#> 41: 2025-09-01      a  9.360877
#> 42: 2025-09-01      b 19.950035
#> 43: 2025-10-01      a  9.748517
#> 44: 2025-10-01      b 20.444797
#> 45: 2025-11-01      a 12.755418
#> 46: 2025-11-01      b 20.046531
#> 47: 2025-12-01      a 10.577709
#> 48: 2025-12-01      b 20.118195
#> 49: 2026-01-01      a  8.088280
#> 50: 2026-01-01      b 20.862086
#> 51: 2026-02-01      a  9.756763
#> 52: 2026-02-01      b 19.793913
#> 53: 2026-03-01      a 10.019178
#> 54: 2026-03-01      b 20.029561
#> 55: 2026-04-01      a 10.549828
#> 56: 2026-04-01      b 17.725885
#> 57: 2026-05-01      a 12.682557
#> 58: 2026-05-01      b 19.638779
#> 59: 2026-06-01      a 10.213356
#> 60: 2026-06-01      b 21.074346
#> 61: 2026-07-01      a  9.334912
#> 62: 2026-07-01      b 21.113952
#> 63: 2026-08-01      a  9.754104
#> 64: 2026-08-01      b 18.822437
#> 65: 2026-09-01      a  9.024149
#> 66: 2026-09-01      b 21.065057
#> 67: 2026-10-01      a 10.131671
#> 68: 2026-10-01      b 20.488629
#> 69: 2026-11-01      a  8.300549
#> 70: 2026-11-01      b 18.529264
#> 71: 2026-12-01      a 10.284150
#> 72: 2026-12-01      b 21.337320
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
flrn = as_learner(ppl("fcst.local", lrn("fcst.ets")))$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.987157
#>    a 2027-02-01       2    NA  9.987157
#>    a 2027-03-01       3    NA  9.987157
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 19.934274
#>    b 2027-11-01      23    NA 19.934274
#>    b 2027-12-01      24    NA 19.934274
```
