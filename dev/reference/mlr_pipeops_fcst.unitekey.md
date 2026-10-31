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
#>  1: 2024-01-01      a 11.454201
#>  2: 2024-01-01      b 18.991976
#>  3: 2024-02-01      a 10.654316
#>  4: 2024-02-01      b 19.148252
#>  5: 2024-03-01      a 11.592099
#>  6: 2024-03-01      b 19.790049
#>  7: 2024-04-01      a  9.988157
#>  8: 2024-04-01      b 19.857566
#>  9: 2024-05-01      a 11.788159
#> 10: 2024-05-01      b 18.486312
#> 11: 2024-06-01      a 10.230869
#> 12: 2024-06-01      b 18.424563
#> 13: 2024-07-01      a 11.798511
#> 14: 2024-07-01      b 19.034140
#> 15: 2024-08-01      a  8.679529
#> 16: 2024-08-01      b 18.912082
#> 17: 2024-09-01      a  9.034412
#> 18: 2024-09-01      b 20.869004
#> 19: 2024-10-01      a  8.330870
#> 20: 2024-10-01      b 19.681585
#> 21: 2024-11-01      a 11.028372
#> 22: 2024-11-01      b 20.704451
#> 23: 2024-12-01      a 11.023511
#> 24: 2024-12-01      b 19.515944
#> 25: 2025-01-01      a  9.574073
#> 26: 2025-01-01      b 17.888000
#> 27: 2025-02-01      a  9.987337
#> 28: 2025-02-01      b 20.329111
#> 29: 2025-03-01      a  7.936061
#> 30: 2025-03-01      b 21.193997
#> 31: 2025-04-01      a 10.603801
#> 32: 2025-04-01      b 18.815751
#> 33: 2025-05-01      a  9.934059
#> 34: 2025-05-01      b 21.808031
#> 35: 2025-06-01      a  9.589677
#> 36: 2025-06-01      b 22.380390
#> 37: 2025-07-01      a 11.096077
#> 38: 2025-07-01      b 18.429083
#> 39: 2025-08-01      a  9.565308
#> 40: 2025-08-01      b 20.927493
#> 41: 2025-09-01      a  7.782660
#> 42: 2025-09-01      b 19.301561
#> 43: 2025-10-01      a  9.961974
#> 44: 2025-10-01      b 21.754916
#> 45: 2025-11-01      a  8.479012
#> 46: 2025-11-01      b 21.961519
#> 47: 2025-12-01      a 10.018139
#> 48: 2025-12-01      b 21.567668
#> 49: 2026-01-01      a 10.785479
#> 50: 2026-01-01      b 18.850440
#> 51: 2026-02-01      a 10.068589
#> 52: 2026-02-01      b 20.839517
#> 53: 2026-03-01      a 10.515121
#> 54: 2026-03-01      b 19.132588
#> 55: 2026-04-01      a  9.311815
#> 56: 2026-04-01      b 20.191471
#> 57: 2026-05-01      a  9.893801
#> 58: 2026-05-01      b 19.682472
#> 59: 2026-06-01      a  9.655784
#> 60: 2026-06-01      b 19.127560
#> 61: 2026-07-01      a 10.686542
#> 62: 2026-07-01      b 19.582762
#> 63: 2026-08-01      a 10.057291
#> 64: 2026-08-01      b 19.861483
#> 65: 2026-09-01      a  9.721512
#> 66: 2026-09-01      b 20.116193
#> 67: 2026-10-01      a 10.022253
#> 68: 2026-10-01      b 20.830774
#> 69: 2026-11-01      a  9.338395
#> 70: 2026-11-01      b 19.316924
#> 71: 2026-12-01      a  9.069912
#> 72: 2026-12-01      b 19.033721
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.782953
#>    a 2027-02-01       2    NA  9.782953
#>    a 2027-03-01       3    NA  9.782953
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 19.898478
#>    b 2027-11-01      23    NA 19.898478
#>    b 2027-12-01      24    NA 19.898478
```
