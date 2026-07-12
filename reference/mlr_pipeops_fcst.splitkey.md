# Split a Forecast Task into Per-Series Tasks

Splits a keyed (multi-series)
[TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md) into
a
[Multiplicity](https://mlr3pipelines.mlr-org.com/reference/Multiplicity.html)
of single-series tasks, one per key combination. Subsequent PipeOps are
executed once per series until a
[`po("fcst.unitekey")`](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.unitekey.md)
is reached, fitting one local model per series instead of one global
model pooled across series.

The per-series tasks carry no key columns, so classical univariate
learners (e.g. `lrn("fcst.ets")`) compose as well. The key groups
observed during training are stored in the `$state` and the task must
contain exactly the same key groups at predict time.

## Parameters

This PipeOp has no parameters.

## Super class

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\> `PipeOpFcstSplitKey`

## Methods

### Public methods

- [`PipeOpFcstSplitKey$new()`](#method-PipeOpFcstSplitKey-initialize)

- [`PipeOpFcstSplitKey$clone()`](#method-PipeOpFcstSplitKey-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstSplitKey$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstSplitKey$new(id = "fcst.splitkey", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.splitkey"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstSplitKey$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstSplitKey$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

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
#>  1: 2024-01-01      a  9.876039
#>  2: 2024-01-01      b 21.761800
#>  3: 2024-02-01      a 10.549439
#>  4: 2024-02-01      b 19.394717
#>  5: 2024-03-01      a  9.920795
#>  6: 2024-03-01      b 19.603865
#>  7: 2024-04-01      a  9.114042
#>  8: 2024-04-01      b 19.546479
#>  9: 2024-05-01      a  8.209519
#> 10: 2024-05-01      b 19.445649
#> 11: 2024-06-01      a 11.175383
#> 12: 2024-06-01      b 19.809078
#> 13: 2024-07-01      a  7.295715
#> 14: 2024-07-01      b 19.784460
#> 15: 2024-08-01      a  9.488636
#> 16: 2024-08-01      b 19.820548
#> 17: 2024-09-01      a  9.716465
#> 18: 2024-09-01      b 20.577705
#> 19: 2024-10-01      a 11.100141
#> 20: 2024-10-01      b 18.742159
#> 21: 2024-11-01      a 10.174536
#> 22: 2024-11-01      b 20.141372
#> 23: 2024-12-01      a  9.927532
#> 24: 2024-12-01      b 17.508537
#> 25: 2025-01-01      a 10.257359
#> 26: 2025-01-01      b 19.570365
#> 27: 2025-02-01      a  8.418684
#> 28: 2025-02-01      b 19.156025
#> 29: 2025-03-01      a  9.943757
#> 30: 2025-03-01      b 19.648092
#> 31: 2025-04-01      a  9.421841
#> 32: 2025-04-01      b 19.188175
#> 33: 2025-05-01      a  9.908244
#> 34: 2025-05-01      b 20.999937
#> 35: 2025-06-01      a  9.612784
#> 36: 2025-06-01      b 19.345995
#> 37: 2025-07-01      a 10.624996
#> 38: 2025-07-01      b 19.935960
#> 39: 2025-08-01      a  9.789072
#> 40: 2025-08-01      b 19.003893
#> 41: 2025-09-01      a  9.406351
#> 42: 2025-09-01      b 20.010337
#> 43: 2025-10-01      a 12.264833
#> 44: 2025-10-01      b 18.878220
#> 45: 2025-11-01      a  9.544570
#> 46: 2025-11-01      b 19.827854
#> 47: 2025-12-01      a  9.495479
#> 48: 2025-12-01      b 19.077010
#> 49: 2026-01-01      a 10.325879
#> 50: 2026-01-01      b 20.518443
#> 51: 2026-02-01      a  7.897335
#> 52: 2026-02-01      b 19.943086
#> 53: 2026-03-01      a 11.560098
#> 54: 2026-03-01      b 20.346810
#> 55: 2026-04-01      a  9.850386
#> 56: 2026-04-01      b 21.709752
#> 57: 2026-05-01      a 11.190533
#> 58: 2026-05-01      b 22.100205
#> 59: 2026-06-01      a 11.062382
#> 60: 2026-06-01      b 21.250466
#> 61: 2026-07-01      a 10.827568
#> 62: 2026-07-01      b 19.795909
#> 63: 2026-08-01      a 11.743422
#> 64: 2026-08-01      b 20.891903
#> 65: 2026-09-01      a 10.102213
#> 66: 2026-09-01      b 19.853436
#> 67: 2026-10-01      a  8.761296
#> 68: 2026-10-01      b 20.158549
#> 69: 2026-11-01      a 10.084187
#> 70: 2026-11-01      b 19.710224
#> 71: 2026-12-01      a  9.788102
#> 72: 2026-12-01      b 17.328683
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.956438
#>    a 2027-02-01       2    NA  9.956438
#>    a 2027-03-01       3    NA  9.956438
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 19.043768
#>    b 2027-11-01      23    NA 19.043768
#>    b 2027-12-01      24    NA 19.043768
```
