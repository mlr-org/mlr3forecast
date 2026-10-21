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
#>  1: 2024-01-01      a 10.637425
#>  2: 2024-01-01      b 20.017027
#>  3: 2024-02-01      a 11.281467
#>  4: 2024-02-01      b 20.950991
#>  5: 2024-03-01      a 10.083900
#>  6: 2024-03-01      b 19.204623
#>  7: 2024-04-01      a 10.201349
#>  8: 2024-04-01      b 21.533675
#>  9: 2024-05-01      a 10.514507
#> 10: 2024-05-01      b 17.736475
#> 11: 2024-06-01      a 10.150826
#> 12: 2024-06-01      b 19.160614
#> 13: 2024-07-01      a 11.220898
#> 14: 2024-07-01      b 19.442797
#> 15: 2024-08-01      a  9.475345
#> 16: 2024-08-01      b 20.531464
#> 17: 2024-09-01      a  9.533984
#> 18: 2024-09-01      b 20.580791
#> 19: 2024-10-01      a  8.989664
#> 20: 2024-10-01      b 19.419957
#> 21: 2024-11-01      a 10.081615
#> 22: 2024-11-01      b 21.032317
#> 23: 2024-12-01      a 11.821413
#> 24: 2024-12-01      b 20.504395
#> 25: 2025-01-01      a 10.444280
#> 26: 2025-01-01      b 18.636941
#> 27: 2025-02-01      a 10.390745
#> 28: 2025-02-01      b 20.585751
#> 29: 2025-03-01      a  8.797913
#> 30: 2025-03-01      b 20.103527
#> 31: 2025-04-01      a  9.164061
#> 32: 2025-04-01      b 19.751603
#> 33: 2025-05-01      a 10.969143
#> 34: 2025-05-01      b 18.995037
#> 35: 2025-06-01      a  9.419315
#> 36: 2025-06-01      b 19.272868
#> 37: 2025-07-01      a  9.856781
#> 38: 2025-07-01      b 19.968702
#> 39: 2025-08-01      a 10.492993
#> 40: 2025-08-01      b 19.718028
#> 41: 2025-09-01      a  9.402817
#> 42: 2025-09-01      b 19.209087
#> 43: 2025-10-01      a 11.631998
#> 44: 2025-10-01      b 20.694318
#> 45: 2025-11-01      a 10.734595
#> 46: 2025-11-01      b 19.798901
#> 47: 2025-12-01      a 10.656981
#> 48: 2025-12-01      b 20.996771
#> 49: 2026-01-01      a 10.097885
#> 50: 2026-01-01      b 22.364711
#> 51: 2026-02-01      a 10.654156
#> 52: 2026-02-01      b 19.471488
#> 53: 2026-03-01      a  9.878468
#> 54: 2026-03-01      b 21.101261
#> 55: 2026-04-01      a  9.442072
#> 56: 2026-04-01      b 20.025637
#> 57: 2026-05-01      a 10.210265
#> 58: 2026-05-01      b 18.598156
#> 59: 2026-06-01      a 10.694427
#> 60: 2026-06-01      b 20.458013
#> 61: 2026-07-01      a  9.633069
#> 62: 2026-07-01      b 19.127325
#> 63: 2026-08-01      a  9.473902
#> 64: 2026-08-01      b 19.880674
#> 65: 2026-09-01      a  8.207703
#> 66: 2026-09-01      b 19.147667
#> 67: 2026-10-01      a  8.763889
#> 68: 2026-10-01      b 20.294362
#> 69: 2026-11-01      a  9.008727
#> 70: 2026-11-01      b 22.540732
#> 71: 2026-12-01      a  9.447512
#> 72: 2026-12-01      b 21.133676
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth  response
#>    a 2027-01-01       1    NA  9.394754
#>    a 2027-02-01       2    NA  9.394754
#>    a 2027-03-01       3    NA  9.394754
#>  ---        ---     ---   ---       ---
#>    b 2027-10-01      22    NA 20.055308
#>    b 2027-11-01      23    NA 20.055308
#>    b 2027-12-01      24    NA 20.055308
```
