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
#>  1: 2024-01-01      a  9.044745
#>  2: 2024-01-01      b 20.341395
#>  3: 2024-02-01      a 10.083357
#>  4: 2024-02-01      b 19.897347
#>  5: 2024-03-01      a 10.552178
#>  6: 2024-03-01      b 18.570253
#>  7: 2024-04-01      a  8.918572
#>  8: 2024-04-01      b 17.627523
#>  9: 2024-05-01      a  9.903787
#> 10: 2024-05-01      b 20.472771
#> 11: 2024-06-01      a  8.197908
#> 12: 2024-06-01      b 20.913269
#> 13: 2024-07-01      a  9.498292
#> 14: 2024-07-01      b 20.396103
#> 15: 2024-08-01      a 10.395472
#> 16: 2024-08-01      b 18.241321
#> 17: 2024-09-01      a 10.696700
#> 18: 2024-09-01      b 18.810967
#> 19: 2024-10-01      a 10.867512
#> 20: 2024-10-01      b 18.717154
#> 21: 2024-11-01      a 10.842715
#> 22: 2024-11-01      b 19.441202
#> 23: 2024-12-01      a 10.541797
#> 24: 2024-12-01      b 18.567266
#> 25: 2025-01-01      a 11.085939
#> 26: 2025-01-01      b 20.931620
#> 27: 2025-02-01      a 10.123805
#> 28: 2025-02-01      b 20.243484
#> 29: 2025-03-01      a 10.776579
#> 30: 2025-03-01      b 20.901291
#> 31: 2025-04-01      a 11.212930
#> 32: 2025-04-01      b 21.086059
#> 33: 2025-05-01      a  9.514831
#> 34: 2025-05-01      b 20.917805
#> 35: 2025-06-01      a  8.783136
#> 36: 2025-06-01      b 19.652602
#> 37: 2025-07-01      a  9.971833
#> 38: 2025-07-01      b 19.915218
#> 39: 2025-08-01      a  8.277186
#> 40: 2025-08-01      b 22.440146
#> 41: 2025-09-01      a 10.146431
#> 42: 2025-09-01      b 20.375285
#> 43: 2025-10-01      a 10.581311
#> 44: 2025-10-01      b 19.865854
#> 45: 2025-11-01      a 10.631658
#> 46: 2025-11-01      b 18.778386
#> 47: 2025-12-01      a  8.530398
#> 48: 2025-12-01      b 20.032431
#> 49: 2026-01-01      a  9.240671
#> 50: 2026-01-01      b 19.006349
#> 51: 2026-02-01      a  9.935952
#> 52: 2026-02-01      b 19.413595
#> 53: 2026-03-01      a  8.851809
#> 54: 2026-03-01      b 19.634404
#> 55: 2026-04-01      a  7.892915
#> 56: 2026-04-01      b 18.674632
#> 57: 2026-05-01      a  8.510975
#> 58: 2026-05-01      b 20.915908
#> 59: 2026-06-01      a 10.931511
#> 60: 2026-06-01      b 20.291610
#> 61: 2026-07-01      a 10.682773
#> 62: 2026-07-01      b 19.389264
#> 63: 2026-08-01      a 12.118948
#> 64: 2026-08-01      b 20.819914
#> 65: 2026-09-01      a  9.804241
#> 66: 2026-09-01      b 19.971188
#> 67: 2026-10-01      a  9.471528
#> 68: 2026-10-01      b 19.551419
#> 69: 2026-11-01      a  9.976107
#> 70: 2026-11-01      b 20.287058
#> 71: 2026-12-01      a  9.835528
#> 72: 2026-12-01      b 20.992938
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.900847
#>    a 2027-02-01       2    NA  9.900847
#>    a 2027-03-01       3    NA  9.900847
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 19.891298
#>    b 2027-11-01      23    NA 19.891298
#>    b 2027-12-01      24    NA 19.891298
```
