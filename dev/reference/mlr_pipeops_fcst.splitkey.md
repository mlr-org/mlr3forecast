# Split a Forecast Task into Per-Series Tasks

Splits a keyed (multi-series)
[TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md)
into a
[Multiplicity](https://mlr3pipelines.mlr-org.com/reference/Multiplicity.html)
of single-series tasks, one per key combination. Subsequent PipeOps are
executed once per series until a
[`po("fcst.unitekey")`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.unitekey.md)
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
#>  1: 2024-01-01      a 10.912875
#>  2: 2024-01-01      b 19.057073
#>  3: 2024-02-01      a 10.684144
#>  4: 2024-02-01      b 19.781732
#>  5: 2024-03-01      a  9.836759
#>  6: 2024-03-01      b 19.659241
#>  7: 2024-04-01      a  9.528505
#>  8: 2024-04-01      b 19.311295
#>  9: 2024-05-01      a  9.946696
#> 10: 2024-05-01      b 20.858034
#> 11: 2024-06-01      a  9.045688
#> 12: 2024-06-01      b 18.016160
#> 13: 2024-07-01      a 10.013682
#> 14: 2024-07-01      b 21.377628
#> 15: 2024-08-01      a 11.597233
#> 16: 2024-08-01      b 20.916572
#> 17: 2024-09-01      a 10.679126
#> 18: 2024-09-01      b 21.633985
#> 19: 2024-10-01      a  8.730316
#> 20: 2024-10-01      b 18.321891
#> 21: 2024-11-01      a 11.009186
#> 22: 2024-11-01      b 20.535830
#> 23: 2024-12-01      a 10.508932
#> 24: 2024-12-01      b 19.739897
#> 25: 2025-01-01      a 10.076977
#> 26: 2025-01-01      b 20.503054
#> 27: 2025-02-01      a  9.627504
#> 28: 2025-02-01      b 19.346394
#> 29: 2025-03-01      a  7.424518
#> 30: 2025-03-01      b 20.516280
#> 31: 2025-04-01      a  9.681194
#> 32: 2025-04-01      b 21.360159
#> 33: 2025-05-01      a  8.616725
#> 34: 2025-05-01      b 19.161386
#> 35: 2025-06-01      a 11.114071
#> 36: 2025-06-01      b 21.046747
#> 37: 2025-07-01      a 10.124508
#> 38: 2025-07-01      b 20.492627
#> 39: 2025-08-01      a  9.561932
#> 40: 2025-08-01      b 18.829681
#> 41: 2025-09-01      a 11.116348
#> 42: 2025-09-01      b 20.082606
#> 43: 2025-10-01      a 11.203065
#> 44: 2025-10-01      b 19.880273
#> 45: 2025-11-01      a 11.404586
#> 46: 2025-11-01      b 18.705707
#> 47: 2025-12-01      a 10.537536
#> 48: 2025-12-01      b 20.717869
#> 49: 2026-01-01      a  8.390800
#> 50: 2026-01-01      b 18.108464
#> 51: 2026-02-01      a 10.546190
#> 52: 2026-02-01      b 20.381790
#> 53: 2026-03-01      a  9.153716
#> 54: 2026-03-01      b 20.889125
#> 55: 2026-04-01      a 10.300104
#> 56: 2026-04-01      b 19.421342
#> 57: 2026-05-01      a  9.122495
#> 58: 2026-05-01      b 19.068284
#> 59: 2026-06-01      a  9.174761
#> 60: 2026-06-01      b 21.205270
#> 61: 2026-07-01      a 10.118175
#> 62: 2026-07-01      b 19.712972
#> 63: 2026-08-01      a 11.166542
#> 64: 2026-08-01      b 21.902131
#> 65: 2026-09-01      a 10.077519
#> 66: 2026-09-01      b 18.461580
#> 67: 2026-10-01      a 12.218796
#> 68: 2026-10-01      b 19.036094
#> 69: 2026-11-01      a 10.220285
#> 70: 2026-11-01      b 21.176409
#> 71: 2026-12-01      a 10.219306
#> 72: 2026-12-01      b 21.717170
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.10255
#>    a 2027-02-01       2    NA 10.10255
#>    a 2027-03-01       3    NA 10.10255
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 20.02576
#>    b 2027-11-01      23    NA 20.02576
#>    b 2027-12-01      24    NA 20.02576
```
