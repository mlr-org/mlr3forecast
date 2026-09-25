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
#>  1: 2024-01-01      a  8.385093
#>  2: 2024-01-01      b 19.547151
#>  3: 2024-02-01      a  9.949346
#>  4: 2024-02-01      b 19.716025
#>  5: 2024-03-01      a  9.388871
#>  6: 2024-03-01      b 20.261511
#>  7: 2024-04-01      a 11.974846
#>  8: 2024-04-01      b 20.628005
#>  9: 2024-05-01      a  9.281027
#> 10: 2024-05-01      b 20.050916
#> 11: 2024-06-01      a  9.903331
#> 12: 2024-06-01      b 20.271803
#> 13: 2024-07-01      a 10.439335
#> 14: 2024-07-01      b 20.075652
#> 15: 2024-08-01      a 10.776910
#> 16: 2024-08-01      b 20.236415
#> 17: 2024-09-01      a  9.167244
#> 18: 2024-09-01      b 20.801817
#> 19: 2024-10-01      a  8.759986
#> 20: 2024-10-01      b 20.822733
#> 21: 2024-11-01      a  9.291113
#> 22: 2024-11-01      b 19.214259
#> 23: 2024-12-01      a 10.275262
#> 24: 2024-12-01      b 21.171616
#> 25: 2025-01-01      a 10.922905
#> 26: 2025-01-01      b 19.667514
#> 27: 2025-02-01      a  8.411460
#> 28: 2025-02-01      b 21.755885
#> 29: 2025-03-01      a 10.624834
#> 30: 2025-03-01      b 19.732471
#> 31: 2025-04-01      a 10.956789
#> 32: 2025-04-01      b 19.236571
#> 33: 2025-05-01      a 10.632603
#> 34: 2025-05-01      b 18.686051
#> 35: 2025-06-01      a  9.494264
#> 36: 2025-06-01      b 20.126237
#> 37: 2025-07-01      a  9.246733
#> 38: 2025-07-01      b 20.590381
#> 39: 2025-08-01      a 10.318253
#> 40: 2025-08-01      b 20.630515
#> 41: 2025-09-01      a  9.594401
#> 42: 2025-09-01      b 21.275725
#> 43: 2025-10-01      a  8.772903
#> 44: 2025-10-01      b 19.734862
#> 45: 2025-11-01      a  9.831856
#> 46: 2025-11-01      b 19.328332
#> 47: 2025-12-01      a  8.859431
#> 48: 2025-12-01      b 20.586031
#> 49: 2026-01-01      a  9.786529
#> 50: 2026-01-01      b 19.675791
#> 51: 2026-02-01      a 10.493847
#> 52: 2026-02-01      b 22.048990
#> 53: 2026-03-01      a 10.097197
#> 54: 2026-03-01      b 20.299045
#> 55: 2026-04-01      a 11.539106
#> 56: 2026-04-01      b 21.400152
#> 57: 2026-05-01      a 12.367225
#> 58: 2026-05-01      b 20.425222
#> 59: 2026-06-01      a  9.692170
#> 60: 2026-06-01      b 19.076237
#> 61: 2026-07-01      a 10.656057
#> 62: 2026-07-01      b 20.422514
#> 63: 2026-08-01      a 10.197522
#> 64: 2026-08-01      b 18.729357
#> 65: 2026-09-01      a 10.131342
#> 66: 2026-09-01      b 18.952094
#> 67: 2026-10-01      a 10.494058
#> 68: 2026-10-01      b 20.432783
#> 69: 2026-11-01      a 10.174223
#> 70: 2026-11-01      b 20.863746
#> 71: 2026-12-01      a  9.975760
#> 72: 2026-12-01      b 19.732657
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.02281
#>    a 2027-02-01       2    NA 10.02281
#>    a 2027-03-01       3    NA 10.02281
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 20.17256
#>    b 2027-11-01      23    NA 20.17256
#>    b 2027-12-01      24    NA 20.17256
```
