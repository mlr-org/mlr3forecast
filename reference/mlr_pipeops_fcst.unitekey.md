# Unite Per-Series Forecasts into One Prediction

Row-binds a
[Multiplicity](https://mlr3pipelines.mlr-org.com/reference/Multiplicity.html)
of per-series
[PredictionFcst](https://mlr3forecast.mlr-org.com/reference/PredictionFcst.md)s,
as created downstream of
[`po("fcst.splitkey")`](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.splitkey.md),
into a single
[PredictionFcst](https://mlr3forecast.mlr-org.com/reference/PredictionFcst.md).

The series identity is rebuilt from the multiplicity names as a factor
column in the prediction's `extra` slot, so `$key`,
[`as.data.table()`](https://rdrr.io/pkg/data.table/man/as.data.table.html),
and
[`autoplot.PredictionFcst()`](https://mlr3forecast.mlr-org.com/reference/autoplot.PredictionFcst.md)
keep working. Multi-column keys are collapsed into one label per series
(values pasted with `":"`). Set `key` to the task's key column name to
get predictions column-compatible with global forecasters such as
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md),
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
#>  1: 2024-01-01      a  9.188187
#>  2: 2024-01-01      b 21.143059
#>  3: 2024-02-01      a  9.949675
#>  4: 2024-02-01      b 20.121750
#>  5: 2024-03-01      a  9.374075
#>  6: 2024-03-01      b 18.551279
#>  7: 2024-04-01      a 10.828167
#>  8: 2024-04-01      b 20.465474
#>  9: 2024-05-01      a  9.414605
#> 10: 2024-05-01      b 20.143192
#> 11: 2024-06-01      a  9.963924
#> 12: 2024-06-01      b 20.578229
#> 13: 2024-07-01      a 11.219388
#> 14: 2024-07-01      b 20.500375
#> 15: 2024-08-01      a  9.459848
#> 16: 2024-08-01      b 18.869620
#> 17: 2024-09-01      a 11.315577
#> 18: 2024-09-01      b 20.958415
#> 19: 2024-10-01      a  9.540601
#> 20: 2024-10-01      b 19.106262
#> 21: 2024-11-01      a 10.983076
#> 22: 2024-11-01      b 21.516601
#> 23: 2024-12-01      a  9.580234
#> 24: 2024-12-01      b 19.417487
#> 25: 2025-01-01      a 12.105053
#> 26: 2025-01-01      b 20.507952
#> 27: 2025-02-01      a  9.932158
#> 28: 2025-02-01      b 19.894820
#> 29: 2025-03-01      a 10.689360
#> 30: 2025-03-01      b 18.791590
#> 31: 2025-04-01      a  9.845567
#> 32: 2025-04-01      b 19.509082
#> 33: 2025-05-01      a  9.561863
#> 34: 2025-05-01      b 19.694724
#> 35: 2025-06-01      a 11.333684
#> 36: 2025-06-01      b 19.051512
#> 37: 2025-07-01      a  8.316814
#> 38: 2025-07-01      b 19.719753
#> 39: 2025-08-01      a 10.318221
#> 40: 2025-08-01      b 19.450666
#> 41: 2025-09-01      a  8.214556
#> 42: 2025-09-01      b 21.531583
#> 43: 2025-10-01      a  8.151789
#> 44: 2025-10-01      b 18.490551
#> 45: 2025-11-01      a 11.627334
#> 46: 2025-11-01      b 18.673032
#> 47: 2025-12-01      a 10.433387
#> 48: 2025-12-01      b 20.791876
#> 49: 2026-01-01      a  9.409305
#> 50: 2026-01-01      b 20.233384
#> 51: 2026-02-01      a 10.439890
#> 52: 2026-02-01      b 20.098231
#> 53: 2026-03-01      a  9.757395
#> 54: 2026-03-01      b 21.875434
#> 55: 2026-04-01      a  9.665855
#> 56: 2026-04-01      b 19.579729
#> 57: 2026-05-01      a 10.857408
#> 58: 2026-05-01      b 19.449339
#> 59: 2026-06-01      a  9.867241
#> 60: 2026-06-01      b 19.690559
#> 61: 2026-07-01      a  9.063706
#> 62: 2026-07-01      b 21.796455
#> 63: 2026-08-01      a  9.074902
#> 64: 2026-08-01      b 19.749409
#> 65: 2026-09-01      a 10.542884
#> 66: 2026-09-01      b 18.478475
#> 67: 2026-10-01      a  8.433545
#> 68: 2026-10-01      b 19.054595
#> 69: 2026-11-01      a 11.269269
#> 70: 2026-11-01      b 20.355569
#> 71: 2026-12-01      a  8.618020
#> 72: 2026-12-01      b 19.314300
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.954075
#>    a 2027-02-01       2    NA  9.954075
#>    a 2027-03-01       3    NA  9.954075
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 19.920991
#>    b 2027-11-01      23    NA 19.920991
#>    b 2027-12-01      24    NA 19.920991
```
