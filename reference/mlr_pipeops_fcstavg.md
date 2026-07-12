# Weighted Prediction Averaging for Forecasts

Performs (weighted) averaging of forecast
[PredictionFcst](https://mlr3forecast.mlr-org.com/reference/PredictionFcst.md)s,
mirroring
[mlr3pipelines::PipeOpRegrAvg](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_regravg.html)
but preserving the forecast prediction type, which plain `regravg` would
drop. The output is a
[PredictionFcst](https://mlr3forecast.mlr-org.com/reference/PredictionFcst.md)
that keeps the time index and key columns (carried in the `extra` slot),
so `$order`, `$key`,
[`autoplot.PredictionFcst()`](https://mlr3forecast.mlr-org.com/reference/autoplot.PredictionFcst.md),
and forecast `task_type` inference keep working through the ensemble.

Connect it to several
[PipeOpLearner](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_learner.html)
outputs (classical forecast learners or
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md)
/
[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md))
to average their forecasts.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpRegrAvg](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_regravg.html).

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpEnsemble`](https://mlr3pipelines.mlr-org.com/reference/PipeOpEnsemble.html)
-\>
[`mlr3pipelines::PipeOpRegrAvg`](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_regravg.html)
-\> `PipeOpFcstAvg`

## Methods

### Public methods

- [`PipeOpFcstAvg$new()`](#method-PipeOpFcstAvg-initialize)

- [`PipeOpFcstAvg$clone()`](#method-PipeOpFcstAvg-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstAvg$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstAvg$new(
      innum = 0L,
      collect_multiplicity = FALSE,
      id = "fcstavg",
      param_vals = list()
    )

#### Arguments

- `innum`:

  (`numeric(1)`)  
  Number of input channels. Default `0` creates a vararg channel taking
  an arbitrary number of inputs.

- `collect_multiplicity`:

  (`logical(1)`)  
  If `TRUE`, the single input is a
  [Multiplicity](https://mlr3pipelines.mlr-org.com/reference/Multiplicity.html)
  collecting channel. Requires `innum = 0`. Default `FALSE`.

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcstavg"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstAvg$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstAvg$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
graph = gunion(list(
  po("learner", lrn("fcst.auto_arima"), id = "arima"),
  po("learner", lrn("fcst.ets"), id = "ets")
)) %>>%
  po("fcstavg")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionFcst> for 12 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>       month row_ids truth response
#>  1961-01-01       1    NA 443.7184
#>  1961-02-01       2    NA 427.2568
#>  1961-03-01       3    NA 472.9142
#>         ---     ---   ---      ---
#>  1961-10-01      10    NA 478.5799
#>  1961-11-01      11    NA 413.0403
#>  1961-12-01      12    NA 458.7385
```
