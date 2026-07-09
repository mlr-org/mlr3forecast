# Difference the Target Variable

Differences the target variable with lag `lag`, producing the new target
`y'_t = y_t - y_{t - lag}`. The first `lag` rows are dropped during
training. Predictions are inverted via stride-`lag` cumulative sums
anchored at the last `lag` training values, yielding original-scale
predictions.

Use `lag = 1` to remove a trend and `lag = 12` (or the seasonal period)
to remove seasonality.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTargetTrafo](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html),
as well as the following:

- `lag` :: `integer(1)`  
  Lag to difference at. Default `1L`.

## Limitations

This PipeOp must not be placed *inside* a
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md)
or
[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md)
graph and is rejected at construction. Inside
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md),
the trafo only transforms the active row at predict time while iterative
features (lags, rolling windows) need transformed values for all
historical rows. Inside
[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md),
each horizon is inverted independently against the training tail, which
is wrong for horizons \>= 2. Use inside a plain
[mlr3pipelines::GraphLearner](https://mlr3pipelines.mlr-org.com/reference/mlr_learners_graph.html)
via `ppl("targettrafo", ...)` for batch prediction, or wrap the
forecaster itself with `ppl("targettrafo", ...)` so all horizons are
inverted together.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTargetTrafo`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html)
-\> `PipeOpTargetTrafoDifference`

## Methods

### Public methods

- [`PipeOpTargetTrafoDifference$new()`](#method-PipeOpTargetTrafoDifference-initialize)

- [`PipeOpTargetTrafoDifference$clone()`](#method-PipeOpTargetTrafoDifference-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpTargetTrafoDifference$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpTargetTrafoDifference$new(id = "fcst.targetdiff", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.targetdiff"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpTargetTrafoDifference$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpTargetTrafoDifference$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# \donttest{
library(mlr3pipelines)
task = tsk("airpassengers")
split = partition(task, ratio = 0.8)
flrn = as_learner(ppl("targettrafo",
  graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
  trafo_pipeop = po("fcst.targetdiff", lag = 1L)
))
flrn$train(task, split$train)
flrn$predict(task, split$test)
#> 
#> ── <PredictionFcst> for 29 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>       month row_ids truth response
#>  1958-08-01     116   505 461.5000
#>  1958-09-01     117   404 429.9286
#>  1958-10-01     118   359 392.4286
#>         ---     ---   ---      ---
#>  1960-10-01     142   461 479.7749
#>  1960-11-01     143   390 485.7124
#>  1960-12-01     144   432 498.3552
# }
```
