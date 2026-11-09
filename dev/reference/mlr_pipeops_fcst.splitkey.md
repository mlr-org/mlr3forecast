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
#>  1: 2024-01-01      a 11.039906
#>  2: 2024-01-01      b 19.403946
#>  3: 2024-02-01      a 11.585128
#>  4: 2024-02-01      b 22.499464
#>  5: 2024-03-01      a 11.152597
#>  6: 2024-03-01      b 18.127906
#>  7: 2024-04-01      a  8.710139
#>  8: 2024-04-01      b 20.509990
#>  9: 2024-05-01      a 10.570813
#> 10: 2024-05-01      b 19.837736
#> 11: 2024-06-01      a 10.571364
#> 12: 2024-06-01      b 20.876775
#> 13: 2024-07-01      a 11.734689
#> 14: 2024-07-01      b 20.180385
#> 15: 2024-08-01      a 10.362400
#> 16: 2024-08-01      b 19.727370
#> 17: 2024-09-01      a  9.275737
#> 18: 2024-09-01      b 20.659421
#> 19: 2024-10-01      a 11.796559
#> 20: 2024-10-01      b 20.498177
#> 21: 2024-11-01      a 11.850608
#> 22: 2024-11-01      b 20.405410
#> 23: 2024-12-01      a 10.678807
#> 24: 2024-12-01      b 21.368816
#> 25: 2025-01-01      a  8.815097
#> 26: 2025-01-01      b 21.325231
#> 27: 2025-02-01      a  6.755454
#> 28: 2025-02-01      b 19.823231
#> 29: 2025-03-01      a  9.078924
#> 30: 2025-03-01      b 18.787017
#> 31: 2025-04-01      a 10.451325
#> 32: 2025-04-01      b 19.149481
#> 33: 2025-05-01      a  9.439826
#> 34: 2025-05-01      b 18.403382
#> 35: 2025-06-01      a 10.625161
#> 36: 2025-06-01      b 20.239863
#> 37: 2025-07-01      a  8.460064
#> 38: 2025-07-01      b 21.245393
#> 39: 2025-08-01      a  8.837453
#> 40: 2025-08-01      b 21.099359
#> 41: 2025-09-01      a  8.608680
#> 42: 2025-09-01      b 21.704547
#> 43: 2025-10-01      a 11.255442
#> 44: 2025-10-01      b 20.829570
#> 45: 2025-11-01      a  9.873702
#> 46: 2025-11-01      b 19.291928
#> 47: 2025-12-01      a  9.319177
#> 48: 2025-12-01      b 19.577241
#> 49: 2026-01-01      a  9.872740
#> 50: 2026-01-01      b 20.310486
#> 51: 2026-02-01      a 10.690894
#> 52: 2026-02-01      b 20.524884
#> 53: 2026-03-01      a  9.211271
#> 54: 2026-03-01      b 19.366793
#> 55: 2026-04-01      a 10.331906
#> 56: 2026-04-01      b 20.501416
#> 57: 2026-05-01      a  8.941894
#> 58: 2026-05-01      b 20.301441
#> 59: 2026-06-01      a 10.597818
#> 60: 2026-06-01      b 20.140281
#> 61: 2026-07-01      a  8.882654
#> 62: 2026-07-01      b 20.869045
#> 63: 2026-08-01      a  8.795357
#> 64: 2026-08-01      b 20.874987
#> 65: 2026-09-01      a 11.967135
#> 66: 2026-09-01      b 20.229529
#> 67: 2026-10-01      a  9.704875
#> 68: 2026-10-01      b 19.583104
#> 69: 2026-11-01      a  8.669069
#> 70: 2026-11-01      b 20.301274
#> 71: 2026-12-01      a 10.540965
#> 72: 2026-12-01      b 21.593928
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.973723
#>    a 2027-02-01       2    NA  9.973723
#>    a 2027-03-01       3    NA  9.973723
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 20.282490
#>    b 2027-11-01      23    NA 20.282490
#>    b 2027-12-01      24    NA 20.282490
```
