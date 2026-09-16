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
#>  1: 2024-01-01      a  9.786428
#>  2: 2024-01-01      b 19.441927
#>  3: 2024-02-01      a 11.710639
#>  4: 2024-02-01      b 21.164329
#>  5: 2024-03-01      a  9.547498
#>  6: 2024-03-01      b 18.240719
#>  7: 2024-04-01      a  8.936998
#>  8: 2024-04-01      b 20.006375
#>  9: 2024-05-01      a 11.745558
#> 10: 2024-05-01      b 20.420869
#> 11: 2024-06-01      a 11.193402
#> 12: 2024-06-01      b 20.327625
#> 13: 2024-07-01      a 10.835312
#> 14: 2024-07-01      b 19.457074
#> 15: 2024-08-01      a  8.981815
#> 16: 2024-08-01      b 20.679850
#> 17: 2024-09-01      a 10.581240
#> 18: 2024-09-01      b 20.316207
#> 19: 2024-10-01      a 10.948150
#> 20: 2024-10-01      b 19.255981
#> 21: 2024-11-01      a 11.333899
#> 22: 2024-11-01      b 20.565658
#> 23: 2024-12-01      a 10.865440
#> 24: 2024-12-01      b 21.187238
#> 25: 2025-01-01      a  9.704201
#> 26: 2025-01-01      b 19.472232
#> 27: 2025-02-01      a 11.861952
#> 28: 2025-02-01      b 20.866145
#> 29: 2025-03-01      a  8.739155
#> 30: 2025-03-01      b 20.498073
#> 31: 2025-04-01      a  9.691255
#> 32: 2025-04-01      b 20.135694
#> 33: 2025-05-01      a  9.603666
#> 34: 2025-05-01      b 20.511775
#> 35: 2025-06-01      a 10.864490
#> 36: 2025-06-01      b 22.589120
#> 37: 2025-07-01      a 10.375707
#> 38: 2025-07-01      b 20.422168
#> 39: 2025-08-01      a  9.328473
#> 40: 2025-08-01      b 20.725511
#> 41: 2025-09-01      a  8.507263
#> 42: 2025-09-01      b 19.976266
#> 43: 2025-10-01      a 11.443594
#> 44: 2025-10-01      b 20.444295
#> 45: 2025-11-01      a  9.322483
#> 46: 2025-11-01      b 20.590907
#> 47: 2025-12-01      a 10.935764
#> 48: 2025-12-01      b 20.856188
#> 49: 2026-01-01      a 10.581342
#> 50: 2026-01-01      b 18.953930
#> 51: 2026-02-01      a 11.111623
#> 52: 2026-02-01      b 20.316966
#> 53: 2026-03-01      a  9.409710
#> 54: 2026-03-01      b 19.815610
#> 55: 2026-04-01      a 10.584000
#> 56: 2026-04-01      b 20.521831
#> 57: 2026-05-01      a 11.342374
#> 58: 2026-05-01      b 20.252660
#> 59: 2026-06-01      a 10.245633
#> 60: 2026-06-01      b 19.968037
#> 61: 2026-07-01      a 10.095007
#> 62: 2026-07-01      b 20.225313
#> 63: 2026-08-01      a 11.099402
#> 64: 2026-08-01      b 21.019735
#> 65: 2026-09-01      a  8.866314
#> 66: 2026-09-01      b 17.813831
#> 67: 2026-10-01      a 10.429666
#> 68: 2026-10-01      b 20.165427
#> 69: 2026-11-01      a  7.705215
#> 70: 2026-11-01      b 18.574898
#> 71: 2026-12-01      a 10.005350
#> 72: 2026-12-01      b 20.924749
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.23113
#>    a 2027-02-01       2    NA 10.23113
#>    a 2027-03-01       3    NA 10.23113
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 20.18612
#>    b 2027-11-01      23    NA 20.18612
#>    b 2027-12-01      24    NA 20.18612
```
