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
#>  1: 2024-01-01      a 11.100875
#>  2: 2024-01-01      b 19.364309
#>  3: 2024-02-01      a 11.029868
#>  4: 2024-02-01      b 19.828123
#>  5: 2024-03-01      a 10.573656
#>  6: 2024-03-01      b 17.917548
#>  7: 2024-04-01      a 10.188233
#>  8: 2024-04-01      b 21.917462
#>  9: 2024-05-01      a 10.769116
#> 10: 2024-05-01      b 20.608026
#> 11: 2024-06-01      a  8.619822
#> 12: 2024-06-01      b 19.442152
#> 13: 2024-07-01      a 10.613881
#> 14: 2024-07-01      b 19.651293
#> 15: 2024-08-01      a  9.149310
#> 16: 2024-08-01      b 17.275047
#> 17: 2024-09-01      a 10.657932
#> 18: 2024-09-01      b 19.034010
#> 19: 2024-10-01      a  8.698371
#> 20: 2024-10-01      b 21.642939
#> 21: 2024-11-01      a  7.809267
#> 22: 2024-11-01      b 18.989481
#> 23: 2024-12-01      a  9.064834
#> 24: 2024-12-01      b 21.832476
#> 25: 2025-01-01      a 10.656352
#> 26: 2025-01-01      b 20.455279
#> 27: 2025-02-01      a 10.540470
#> 28: 2025-02-01      b 20.223877
#> 29: 2025-03-01      a 10.027134
#> 30: 2025-03-01      b 20.652621
#> 31: 2025-04-01      a 11.361794
#> 32: 2025-04-01      b 20.378654
#> 33: 2025-05-01      a  9.266636
#> 34: 2025-05-01      b 19.606512
#> 35: 2025-06-01      a  9.249880
#> 36: 2025-06-01      b 18.552940
#> 37: 2025-07-01      a  9.702551
#> 38: 2025-07-01      b 20.297915
#> 39: 2025-08-01      a 12.753330
#> 40: 2025-08-01      b 19.646883
#> 41: 2025-09-01      a 10.710988
#> 42: 2025-09-01      b 19.535428
#> 43: 2025-10-01      a  7.905094
#> 44: 2025-10-01      b 20.366030
#> 45: 2025-11-01      a 10.302709
#> 46: 2025-11-01      b 20.955454
#> 47: 2025-12-01      a 10.396080
#> 48: 2025-12-01      b 18.495354
#> 49: 2026-01-01      a  9.447643
#> 50: 2026-01-01      b 19.515022
#> 51: 2026-02-01      a  7.950517
#> 52: 2026-02-01      b 21.690028
#> 53: 2026-03-01      a 11.420800
#> 54: 2026-03-01      b 19.888324
#> 55: 2026-04-01      a 11.082864
#> 56: 2026-04-01      b 18.681317
#> 57: 2026-05-01      a 12.171134
#> 58: 2026-05-01      b 20.487448
#> 59: 2026-06-01      a 10.200932
#> 60: 2026-06-01      b 20.975111
#> 61: 2026-07-01      a 10.207482
#> 62: 2026-07-01      b 19.874520
#> 63: 2026-08-01      a 11.228298
#> 64: 2026-08-01      b 20.394171
#> 65: 2026-09-01      a 10.197074
#> 66: 2026-09-01      b 18.629061
#> 67: 2026-10-01      a 10.994797
#> 68: 2026-10-01      b 21.349383
#> 69: 2026-11-01      a 10.199267
#> 70: 2026-11-01      b 18.495077
#> 71: 2026-12-01      a  9.138922
#> 72: 2026-12-01      b 18.852746
#>          month     id     value
#>         <Date> <fctr>     <num>
task = as_task_fcst(dt, target = "value", order = "month", key = "id", freq = "month")
graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 24 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  key      month row_ids truth response
#>    a 2027-01-01       1    NA 10.14988
#>    a 2027-02-01       2    NA 10.14988
#>    a 2027-03-01       3    NA 10.14988
#>  ---        ---     ---   ---      ---
#>    b 2027-10-01      22    NA 19.87513
#>    b 2027-11-01      23    NA 19.87513
#>    b 2027-12-01      24    NA 19.87513
```
