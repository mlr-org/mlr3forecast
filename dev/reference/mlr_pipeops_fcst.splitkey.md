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
#>  1: 2024-01-01      a 10.741361
#>  2: 2024-01-01      b 21.182667
#>  3: 2024-02-01      a  9.369251
#>  4: 2024-02-01      b 20.995600
#>  5: 2024-03-01      a  9.945241
#>  6: 2024-03-01      b 20.693666
#>  7: 2024-04-01      a 10.144764
#>  8: 2024-04-01      b 20.096864
#>  9: 2024-05-01      a  9.703244
#> 10: 2024-05-01      b 21.941870
#> 11: 2024-06-01      a  9.165647
#> 12: 2024-06-01      b 21.268379
#> 13: 2024-07-01      a  9.546263
#> 14: 2024-07-01      b 20.969214
#> 15: 2024-08-01      a  9.387726
#> 16: 2024-08-01      b 19.198408
#> 17: 2024-09-01      a  9.674009
#> 18: 2024-09-01      b 21.286027
#> 19: 2024-10-01      a  9.405770
#> 20: 2024-10-01      b 20.199349
#> 21: 2024-11-01      a 10.405726
#> 22: 2024-11-01      b 18.709583
#> 23: 2024-12-01      a 10.278488
#> 24: 2024-12-01      b 21.009930
#> 25: 2025-01-01      a 10.157958
#> 26: 2025-01-01      b 18.035569
#> 27: 2025-02-01      a  9.514885
#> 28: 2025-02-01      b 21.009275
#> 29: 2025-03-01      a  9.406281
#> 30: 2025-03-01      b 20.334165
#> 31: 2025-04-01      a 10.660785
#> 32: 2025-04-01      b 19.541010
#> 33: 2025-05-01      a  7.863617
#> 34: 2025-05-01      b 17.148038
#> 35: 2025-06-01      a 10.118329
#> 36: 2025-06-01      b 20.655020
#> 37: 2025-07-01      a  9.557670
#> 38: 2025-07-01      b 19.973752
#> 39: 2025-08-01      a 12.159045
#> 40: 2025-08-01      b 20.569439
#> 41: 2025-09-01      a 10.885803
#> 42: 2025-09-01      b 18.553306
#> 43: 2025-10-01      a 11.102637
#> 44: 2025-10-01      b 19.400077
#> 45: 2025-11-01      a 10.363591
#> 46: 2025-11-01      b 19.963923
#> 47: 2025-12-01      a 10.968626
#> 48: 2025-12-01      b 20.796820
#> 49: 2026-01-01      a 10.388106
#> 50: 2026-01-01      b 19.579021
#> 51: 2026-02-01      a  9.441636
#> 52: 2026-02-01      b 20.922563
#> 53: 2026-03-01      a  9.113138
#> 54: 2026-03-01      b 19.912454
#> 55: 2026-04-01      a 11.004858
#> 56: 2026-04-01      b 19.746827
#> 57: 2026-05-01      a  8.859827
#> 58: 2026-05-01      b 18.007531
#> 59: 2026-06-01      a 10.579921
#> 60: 2026-06-01      b 20.851999
#> 61: 2026-07-01      a 10.044869
#> 62: 2026-07-01      b 19.313775
#> 63: 2026-08-01      a 10.026568
#> 64: 2026-08-01      b 18.967778
#> 65: 2026-09-01      a 11.339436
#> 66: 2026-09-01      b 20.784492
#> 67: 2026-10-01      a 11.945941
#> 68: 2026-10-01      b 20.066625
#> 69: 2026-11-01      a  9.390564
#> 70: 2026-11-01      b 19.514960
#> 71: 2026-12-01      a  9.717598
#> 72: 2026-12-01      b 19.782904
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.06628
#>    a 2027-02-01       2    NA 10.06628
#>    a 2027-03-01       3    NA 10.06628
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 19.83980
#>    b 2027-11-01      23    NA 19.83980
#>    b 2027-12-01      24    NA 19.83980
```
