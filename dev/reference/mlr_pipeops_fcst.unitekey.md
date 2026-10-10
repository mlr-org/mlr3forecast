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
#>  1: 2024-01-01      a  8.967571
#>  2: 2024-01-01      b 19.966172
#>  3: 2024-02-01      a  8.912683
#>  4: 2024-02-01      b 20.310871
#>  5: 2024-03-01      a  8.536473
#>  6: 2024-03-01      b 19.536827
#>  7: 2024-04-01      a 10.105414
#>  8: 2024-04-01      b 19.048204
#>  9: 2024-05-01      a  9.718747
#> 10: 2024-05-01      b 19.247108
#> 11: 2024-06-01      a  9.090683
#> 12: 2024-06-01      b 20.394158
#> 13: 2024-07-01      a 11.596392
#> 14: 2024-07-01      b 19.350772
#> 15: 2024-08-01      a 12.081119
#> 16: 2024-08-01      b 19.511986
#> 17: 2024-09-01      a  8.900225
#> 18: 2024-09-01      b 21.299598
#> 19: 2024-10-01      a 10.400151
#> 20: 2024-10-01      b 18.779889
#> 21: 2024-11-01      a 10.553117
#> 22: 2024-11-01      b 20.327243
#> 23: 2024-12-01      a 11.113760
#> 24: 2024-12-01      b 19.474280
#> 25: 2025-01-01      a 10.591272
#> 26: 2025-01-01      b 21.553870
#> 27: 2025-02-01      a 10.170834
#> 28: 2025-02-01      b 20.342266
#> 29: 2025-03-01      a 10.564291
#> 30: 2025-03-01      b 21.053650
#> 31: 2025-04-01      a 11.219321
#> 32: 2025-04-01      b 20.209470
#> 33: 2025-05-01      a  9.754706
#> 34: 2025-05-01      b 20.539486
#> 35: 2025-06-01      a 10.242755
#> 36: 2025-06-01      b 18.893758
#> 37: 2025-07-01      a 11.106247
#> 38: 2025-07-01      b 21.217427
#> 39: 2025-08-01      a  9.527885
#> 40: 2025-08-01      b 18.299599
#> 41: 2025-09-01      a  9.203796
#> 42: 2025-09-01      b 19.691907
#> 43: 2025-10-01      a 11.230037
#> 44: 2025-10-01      b 19.013557
#> 45: 2025-11-01      a 10.129561
#> 46: 2025-11-01      b 21.088809
#> 47: 2025-12-01      a 10.301359
#> 48: 2025-12-01      b 21.986260
#> 49: 2026-01-01      a 10.553348
#> 50: 2026-01-01      b 18.483684
#> 51: 2026-02-01      a  8.962829
#> 52: 2026-02-01      b 18.348839
#> 53: 2026-03-01      a 10.438046
#> 54: 2026-03-01      b 19.891723
#> 55: 2026-04-01      a  9.352022
#> 56: 2026-04-01      b 20.017484
#> 57: 2026-05-01      a 11.099748
#> 58: 2026-05-01      b 19.484424
#> 59: 2026-06-01      a  9.387909
#> 60: 2026-06-01      b 21.745038
#> 61: 2026-07-01      a 12.166454
#> 62: 2026-07-01      b 20.337791
#> 63: 2026-08-01      a  9.017640
#> 64: 2026-08-01      b 21.441857
#> 65: 2026-09-01      a 10.929968
#> 66: 2026-09-01      b 19.768880
#> 67: 2026-10-01      a 10.109330
#> 68: 2026-10-01      b 18.498580
#> 69: 2026-11-01      a  9.419461
#> 70: 2026-11-01      b 20.896186
#> 71: 2026-12-01      a  8.848897
#> 72: 2026-12-01      b 20.582927
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.08247
#>    a 2027-02-01       2    NA 10.08247
#>    a 2027-03-01       3    NA 10.08247
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 20.01787
#>    b 2027-11-01      23    NA 20.01787
#>    b 2027-12-01      24    NA 20.01787
```
