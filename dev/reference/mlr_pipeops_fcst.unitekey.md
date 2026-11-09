# Unite Per-Series Forecasts into One Prediction

Row-binds a
[Multiplicity](https://mlr3pipelines.mlr-org.com/reference/Multiplicity.html)
of per-series
[PredictionFcst](https://mlr3forecast.mlr-org.com/dev/reference/PredictionFcst.md)s,
as created downstream of
[`po("fcst.splitkey")`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.splitkey.md),
into a single
[PredictionFcst](https://mlr3forecast.mlr-org.com/dev/reference/PredictionFcst.md).

The series identity is rebuilt from the multiplicity names in the
prediction's `extra` slot, and its role is stored in `col_roles`. This
keeps `$key`,
[`as.data.table()`](https://rdrr.io/pkg/data.table/man/as.data.table.html),
and
[`autoplot.PredictionFcst()`](https://mlr3forecast.mlr-org.com/dev/reference/autoplot.PredictionFcst.md)
working. Set `key` to the task's key column name to get predictions
column-compatible with global forecasters such as
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md),
which attach the original key column.

## Parameters

- `key` :: `character(1)`  
  Name of the rebuilt series-identity column in the prediction's `extra`
  slot. Default `"key"`.

## Super class

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\> `PipeOpFcstUniteKey`

## Methods

### Public methods

- [`PipeOpFcstUniteKey$new()`](#method-PipeOpFcstUniteKey-initialize)

- [`PipeOpFcstUniteKey$clone()`](#method-PipeOpFcstUniteKey-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstUniteKey$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstUniteKey$new(id = "fcst.unitekey", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.unitekey"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstUniteKey$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstUniteKey$clone(deep = FALSE)

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
#>  1: 2024-01-01      a  8.764716
#>  2: 2024-01-01      b 20.734325
#>  3: 2024-02-01      a  9.412595
#>  4: 2024-02-01      b 18.481359
#>  5: 2024-03-01      a  9.879520
#>  6: 2024-03-01      b 21.594868
#>  7: 2024-04-01      a  9.708829
#>  8: 2024-04-01      b 19.339126
#>  9: 2024-05-01      a 11.570489
#> 10: 2024-05-01      b 20.049880
#> 11: 2024-06-01      a  9.423585
#> 12: 2024-06-01      b 20.545396
#> 13: 2024-07-01      a  9.307879
#> 14: 2024-07-01      b 20.910059
#> 15: 2024-08-01      a 12.019359
#> 16: 2024-08-01      b 21.137354
#> 17: 2024-09-01      a  9.768247
#> 18: 2024-09-01      b 22.346111
#> 19: 2024-10-01      a 11.086537
#> 20: 2024-10-01      b 21.359623
#> 21: 2024-11-01      a  9.388355
#> 22: 2024-11-01      b 21.633560
#> 23: 2024-12-01      a  9.341228
#> 24: 2024-12-01      b 19.464693
#> 25: 2025-01-01      a  9.746179
#> 26: 2025-01-01      b 20.881497
#> 27: 2025-02-01      a 10.319525
#> 28: 2025-02-01      b 19.932281
#> 29: 2025-03-01      a 11.796247
#> 30: 2025-03-01      b 20.572216
#> 31: 2025-04-01      a  9.723832
#> 32: 2025-04-01      b 20.782412
#> 33: 2025-05-01      a  9.086992
#> 34: 2025-05-01      b 20.661820
#> 35: 2025-06-01      a  8.945269
#> 36: 2025-06-01      b 20.177070
#> 37: 2025-07-01      a 10.022541
#> 38: 2025-07-01      b 19.459312
#> 39: 2025-08-01      a  7.222272
#> 40: 2025-08-01      b 21.372754
#> 41: 2025-09-01      a  8.883946
#> 42: 2025-09-01      b 20.037365
#> 43: 2025-10-01      a  8.057067
#> 44: 2025-10-01      b 20.966207
#> 45: 2025-11-01      a 11.165288
#> 46: 2025-11-01      b 19.020851
#> 47: 2025-12-01      a  9.359903
#> 48: 2025-12-01      b 20.771497
#> 49: 2026-01-01      a  7.659967
#> 50: 2026-01-01      b 21.593503
#> 51: 2026-02-01      a  9.214223
#> 52: 2026-02-01      b 20.589816
#> 53: 2026-03-01      a  7.350298
#> 54: 2026-03-01      b 19.784546
#> 55: 2026-04-01      a  8.148199
#> 56: 2026-04-01      b 21.338890
#> 57: 2026-05-01      a 10.179062
#> 58: 2026-05-01      b 19.937097
#> 59: 2026-06-01      a 10.391263
#> 60: 2026-06-01      b 19.368371
#> 61: 2026-07-01      a  9.069161
#> 62: 2026-07-01      b 19.865499
#> 63: 2026-08-01      a 11.487771
#> 64: 2026-08-01      b 18.997175
#> 65: 2026-09-01      a 10.297362
#> 66: 2026-09-01      b 19.480537
#> 67: 2026-10-01      a  9.855997
#> 68: 2026-10-01      b 20.509179
#> 69: 2026-11-01      a 11.705259
#> 70: 2026-11-01      b 21.491723
#> 71: 2026-12-01      a  9.973045
#> 72: 2026-12-01      b 19.679560
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.703563
#>    a 2027-02-01       2    NA  9.703563
#>    a 2027-03-01       3    NA  9.703563
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 20.413005
#>    b 2027-11-01      23    NA 20.413005
#>    b 2027-12-01      24    NA 20.413005
```
