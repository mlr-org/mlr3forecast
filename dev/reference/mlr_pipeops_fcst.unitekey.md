# Unite Per-Series Forecasts into One Prediction

Row-binds a
[Multiplicity](https://mlr3pipelines.mlr-org.com/reference/Multiplicity.html)
of per-series
[PredictionFcst](https://mlr3forecast.mlr-org.com/dev/reference/PredictionFcst.md)s
or regression predictions, as created downstream of
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
#>  1: 2024-01-01      a 10.666545
#>  2: 2024-01-01      b 20.266795
#>  3: 2024-02-01      a 10.520292
#>  4: 2024-02-01      b 19.137203
#>  5: 2024-03-01      a 10.570345
#>  6: 2024-03-01      b 20.786312
#>  7: 2024-04-01      a  9.738356
#>  8: 2024-04-01      b 22.623503
#>  9: 2024-05-01      a 10.895910
#> 10: 2024-05-01      b 19.007365
#> 11: 2024-06-01      a  9.429237
#> 12: 2024-06-01      b 18.435633
#> 13: 2024-07-01      a  8.204580
#> 14: 2024-07-01      b 18.832503
#> 15: 2024-08-01      a  9.298421
#> 16: 2024-08-01      b 19.197883
#> 17: 2024-09-01      a 10.933742
#> 18: 2024-09-01      b 18.132032
#> 19: 2024-10-01      a  9.509183
#> 20: 2024-10-01      b 20.377460
#> 21: 2024-11-01      a 10.559131
#> 22: 2024-11-01      b 19.689635
#> 23: 2024-12-01      a  8.957614
#> 24: 2024-12-01      b 20.040282
#> 25: 2025-01-01      a 10.422448
#> 26: 2025-01-01      b 19.948706
#> 27: 2025-02-01      a 10.564124
#> 28: 2025-02-01      b 19.167594
#> 29: 2025-03-01      a 10.941847
#> 30: 2025-03-01      b 20.287689
#> 31: 2025-04-01      a 10.683074
#> 32: 2025-04-01      b 21.529718
#> 33: 2025-05-01      a 10.580452
#> 34: 2025-05-01      b 18.469732
#> 35: 2025-06-01      a 11.252742
#> 36: 2025-06-01      b 20.787445
#> 37: 2025-07-01      a 11.252627
#> 38: 2025-07-01      b 21.516151
#> 39: 2025-08-01      a 10.084994
#> 40: 2025-08-01      b 22.586955
#> 41: 2025-09-01      a 11.198502
#> 42: 2025-09-01      b 20.096893
#> 43: 2025-10-01      a 10.417556
#> 44: 2025-10-01      b 18.688904
#> 45: 2025-11-01      a  9.717872
#> 46: 2025-11-01      b 20.135117
#> 47: 2025-12-01      a  8.856536
#> 48: 2025-12-01      b 20.822347
#> 49: 2026-01-01      a  9.855755
#> 50: 2026-01-01      b 20.303234
#> 51: 2026-02-01      a  8.534037
#> 52: 2026-02-01      b 20.833555
#> 53: 2026-03-01      a  8.999242
#> 54: 2026-03-01      b 19.523759
#> 55: 2026-04-01      a 10.631231
#> 56: 2026-04-01      b 20.521944
#> 57: 2026-05-01      a 10.566641
#> 58: 2026-05-01      b 19.004074
#> 59: 2026-06-01      a  9.042084
#> 60: 2026-06-01      b 19.177228
#> 61: 2026-07-01      a 10.054965
#> 62: 2026-07-01      b 20.899680
#> 63: 2026-08-01      a 11.861922
#> 64: 2026-08-01      b 20.295528
#> 65: 2026-09-01      a  9.004941
#> 66: 2026-09-01      b 19.119339
#> 67: 2026-10-01      a  9.637522
#> 68: 2026-10-01      b 19.786696
#> 69: 2026-11-01      a  8.504176
#> 70: 2026-11-01      b 20.197165
#> 71: 2026-12-01      a  9.953290
#> 72: 2026-12-01      b 20.129192
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.05284
#>    a 2027-02-01       2    NA 10.05284
#>    a 2027-03-01       3    NA 10.05284
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 20.01020
#>    b 2027-11-01      23    NA 20.01020
#>    b 2027-12-01      24    NA 20.01020
```
