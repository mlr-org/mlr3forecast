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
#>  1: 2024-01-01      a  9.898442
#>  2: 2024-01-01      b 19.652186
#>  3: 2024-02-01      a  9.783453
#>  4: 2024-02-01      b 19.845390
#>  5: 2024-03-01      a 11.070897
#>  6: 2024-03-01      b 20.285212
#>  7: 2024-04-01      a 10.177422
#>  8: 2024-04-01      b 19.251338
#>  9: 2024-05-01      a  9.594801
#> 10: 2024-05-01      b 20.430672
#> 11: 2024-06-01      a 10.332190
#> 12: 2024-06-01      b 19.148471
#> 13: 2024-07-01      a 10.508177
#> 14: 2024-07-01      b 20.342937
#> 15: 2024-08-01      a 10.797467
#> 16: 2024-08-01      b 20.492099
#> 17: 2024-09-01      a 10.000201
#> 18: 2024-09-01      b 20.440728
#> 19: 2024-10-01      a  7.901976
#> 20: 2024-10-01      b 18.820280
#> 21: 2024-11-01      a 11.090096
#> 22: 2024-11-01      b 20.246120
#> 23: 2024-12-01      a 13.195688
#> 24: 2024-12-01      b 18.450169
#> 25: 2025-01-01      a 10.262374
#> 26: 2025-01-01      b 19.765563
#> 27: 2025-02-01      a 10.258688
#> 28: 2025-02-01      b 19.892657
#> 29: 2025-03-01      a  9.543547
#> 30: 2025-03-01      b 20.218765
#> 31: 2025-04-01      a 10.185123
#> 32: 2025-04-01      b 19.413582
#> 33: 2025-05-01      a 10.444233
#> 34: 2025-05-01      b 19.846325
#> 35: 2025-06-01      a 10.430361
#> 36: 2025-06-01      b 20.117095
#> 37: 2025-07-01      a  9.144936
#> 38: 2025-07-01      b 20.698055
#> 39: 2025-08-01      a  9.849024
#> 40: 2025-08-01      b 19.993036
#> 41: 2025-09-01      a 10.022974
#> 42: 2025-09-01      b 22.466627
#> 43: 2025-10-01      a  9.895910
#> 44: 2025-10-01      b 18.759665
#> 45: 2025-11-01      a  8.250849
#> 46: 2025-11-01      b 20.522025
#> 47: 2025-12-01      a  9.576795
#> 48: 2025-12-01      b 21.685318
#> 49: 2026-01-01      a 10.328306
#> 50: 2026-01-01      b 21.059571
#> 51: 2026-02-01      a  9.985399
#> 52: 2026-02-01      b 21.628954
#> 53: 2026-03-01      a 11.663738
#> 54: 2026-03-01      b 18.917574
#> 55: 2026-04-01      a 10.360180
#> 56: 2026-04-01      b 20.934533
#> 57: 2026-05-01      a 11.804564
#> 58: 2026-05-01      b 20.118186
#> 59: 2026-06-01      a 10.349533
#> 60: 2026-06-01      b 20.418850
#> 61: 2026-07-01      a 10.002994
#> 62: 2026-07-01      b 19.376459
#> 63: 2026-08-01      a  7.706761
#> 64: 2026-08-01      b 20.511339
#> 65: 2026-09-01      a 12.772116
#> 66: 2026-09-01      b 18.295934
#> 67: 2026-10-01      a 10.773717
#> 68: 2026-10-01      b 19.698271
#> 69: 2026-11-01      a  7.995158
#> 70: 2026-11-01      b 17.421517
#> 71: 2026-12-01      a 10.663002
#> 72: 2026-12-01      b 19.495032
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.18404
#>    a 2027-02-01       2    NA 10.18404
#>    a 2027-03-01       3    NA 10.18404
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 19.38069
#>    b 2027-11-01      23    NA 19.38069
#>    b 2027-12-01      24    NA 19.38069
```
