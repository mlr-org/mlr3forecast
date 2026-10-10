# Scale the Target Variable

Centers and scales the target variable, producing the new target
`(y - center) / scale`. On keyed (multi-series) tasks each series is
centered and scaled with its own statistics, putting all series on a
comparable scale for a global model. The transformation is affine and
monotonic, so no rows are dropped and predictions, including quantiles,
are inverted pointwise back to the original scale. Standard errors are
multiplied by the scale. Predicting a series not seen during training is
an error.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTargetTrafo](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html),
as well as the following:

- `center` :: `logical(1)`  
  Whether to center the target by subtracting its mean (median if
  `robust`). Default `TRUE`.

- `scale` :: `logical(1)`  
  Whether to divide the target by its root-mean-square (median absolute
  deviation if `robust`), computed after centering. Constant series are
  left unscaled. Default `TRUE`.

- `robust` :: `logical(1)`  
  Whether to center and scale with the median and median absolute
  deviation instead of the mean and root-mean-square. Default `FALSE`.

## Limitations

This PipeOp must not be placed *inside* a
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md)
graph and is rejected at construction. Inside a
[DirectForecaster](https://mlr3forecast.mlr-org.com/dev/reference/DirectForecaster.md)
graph it works, but each horizon's model computes its own statistics
from the rows it is trained on. Use it inside a plain
[mlr3pipelines::GraphLearner](https://mlr3pipelines.mlr-org.com/reference/mlr_learners_graph.html)
via `ppl("targettrafo", ...)`, or wrap the forecaster itself with
`ppl("targettrafo", ...)` so all horizons share the same statistics.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTargetTrafo`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html)
-\> `PipeOpTargetTrafoScale`

## Methods

### Public methods

- [`PipeOpTargetTrafoScale$new()`](#method-PipeOpTargetTrafoScale-initialize)

- [`PipeOpTargetTrafoScale$clone()`](#method-PipeOpTargetTrafoScale-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpTargetTrafoScale$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpTargetTrafoScale$new(id = "fcst.targetscale", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.targetscale"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpTargetTrafoScale$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpTargetTrafoScale$clone(deep = FALSE)

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
  trafo_pipeop = po("fcst.targetscale")
))
flrn$train(task, split$train)
flrn$predict(task, split$test)
#> 
#> ── <PredictionFcst> for 29 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>       month row_ids truth response
#>  1958-08-01     116   505 391.9375
#>  1958-09-01     117   404 324.7500
#>  1958-10-01     118   359 306.0000
#>         ---     ---   ---      ---
#>  1960-10-01     142   461 368.6875
#>  1960-11-01     143   390 364.9333
#>  1960-12-01     144   432 362.3571
# }
```
