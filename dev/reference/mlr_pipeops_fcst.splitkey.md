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

Each per-series task gets an in-memory backend holding only the rows of
its series. PipeOps that read history beyond the task rows, such as
[`po("fcst.lags")`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.lags.md)
at predict time, therefore see the history of their own series only.

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
#>  1: 2024-01-01      a  8.080783
#>  2: 2024-01-01      b 18.782923
#>  3: 2024-02-01      a 11.199187
#>  4: 2024-02-01      b 19.383218
#>  5: 2024-03-01      a 10.428611
#>  6: 2024-03-01      b 21.070865
#>  7: 2024-04-01      a  9.606852
#>  8: 2024-04-01      b 20.000786
#>  9: 2024-05-01      a  9.686495
#> 10: 2024-05-01      b 16.845008
#> 11: 2024-06-01      a 10.163356
#> 12: 2024-06-01      b 20.056823
#> 13: 2024-07-01      a 10.688819
#> 14: 2024-07-01      b 19.352596
#> 15: 2024-08-01      a 10.877018
#> 16: 2024-08-01      b 18.739096
#> 17: 2024-09-01      a  9.116460
#> 18: 2024-09-01      b 19.417253
#> 19: 2024-10-01      a  9.137307
#> 20: 2024-10-01      b 19.219821
#> 21: 2024-11-01      a 10.490407
#> 22: 2024-11-01      b 20.130811
#> 23: 2024-12-01      a  9.514866
#> 24: 2024-12-01      b 20.900670
#> 25: 2025-01-01      a 11.145876
#> 26: 2025-01-01      b 20.871495
#> 27: 2025-02-01      a 11.589255
#> 28: 2025-02-01      b 18.961764
#> 29: 2025-03-01      a  8.298604
#> 30: 2025-03-01      b 20.739370
#> 31: 2025-04-01      a 13.093133
#> 32: 2025-04-01      b 20.844029
#> 33: 2025-05-01      a 10.464230
#> 34: 2025-05-01      b 19.652825
#> 35: 2025-06-01      a  8.955293
#> 36: 2025-06-01      b 20.449391
#> 37: 2025-07-01      a 10.048864
#> 38: 2025-07-01      b 21.400854
#> 39: 2025-08-01      a 10.601695
#> 40: 2025-08-01      b 20.447945
#> 41: 2025-09-01      a  9.965694
#> 42: 2025-09-01      b 20.175746
#> 43: 2025-10-01      a  8.766569
#> 44: 2025-10-01      b 19.198801
#> 45: 2025-11-01      a  9.561094
#> 46: 2025-11-01      b 21.265327
#> 47: 2025-12-01      a 10.486111
#> 48: 2025-12-01      b 18.793041
#> 49: 2026-01-01      a  9.394103
#> 50: 2026-01-01      b 20.433317
#> 51: 2026-02-01      a 10.831942
#> 52: 2026-02-01      b 19.120909
#> 53: 2026-03-01      a  9.673791
#> 54: 2026-03-01      b 19.960713
#> 55: 2026-04-01      a 10.548511
#> 56: 2026-04-01      b 21.003862
#> 57: 2026-05-01      a  8.989949
#> 58: 2026-05-01      b 20.095529
#> 59: 2026-06-01      a  9.744459
#> 60: 2026-06-01      b 20.585983
#> 61: 2026-07-01      a  9.341458
#> 62: 2026-07-01      b 18.937412
#> 63: 2026-08-01      a  9.382527
#> 64: 2026-08-01      b 20.549912
#> 65: 2026-09-01      a 10.706176
#> 66: 2026-09-01      b 20.363615
#> 67: 2026-10-01      a  9.801810
#> 68: 2026-10-01      b 21.268591
#> 69: 2026-11-01      a  9.307025
#> 70: 2026-11-01      b 21.624568
#> 71: 2026-12-01      a  8.355704
#> 72: 2026-12-01      b 19.006698
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.945841
#>    a 2027-02-01       2    NA  9.945841
#>    a 2027-03-01       3    NA  9.945841
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 19.990073
#>    b 2027-11-01      23    NA 19.990073
#>    b 2027-12-01      24    NA 19.990073
```
