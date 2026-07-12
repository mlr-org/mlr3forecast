# Box-Cox Transform the Target Variable

Applies a Box-Cox transformation to the target variable to stabilize the
variance, producing the new target `BoxCox(y, lambda)`. The
transformation is pointwise and monotonic, so no rows are dropped and
predictions are inverted via
[`forecast::InvBoxCox()`](https://pkg.robjhyndman.com/forecast/reference/BoxCox.html).
`lambda = 0` is the log transformation. When `lambda` is `NULL`
(default) it is estimated from the training data, per series on keyed
tasks. Predicting a series not seen during training is an error.

Box-Cox and log transformations require strictly positive target values.
Non-positive values produce `NaN` or an error. A negative estimated
`lambda` can make
[`forecast::InvBoxCox()`](https://pkg.robjhyndman.com/forecast/reference/BoxCox.html)
return `NA` for upper quantiles. Set `lower = 0` to avoid this.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTargetTrafo](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html),
as well as the following:

- `lambda` :: `numeric(1)` \| `NULL`  
  Box-Cox transformation parameter. `NULL` (default) estimates it from
  the training data, `0` is the log transformation, any other numeric is
  used as a fixed value.

- `method` :: `character(1)`  
  Method used to estimate `lambda` when `lambda = NULL`, one of
  `"guerrero"` (default) or `"loglik"`. See
  [`forecast::BoxCox.lambda()`](https://pkg.robjhyndman.com/forecast/reference/BoxCox.lambda.html).

- `lower` :: `numeric(1)`  
  Lower bound for the estimated `lambda`. Default `-1`.

- `upper` :: `numeric(1)`  
  Upper bound for the estimated `lambda`. Default `2`.

## Limitations

This PipeOp must not be placed *inside* a
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md)
or
[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md)
graph and is rejected at construction. Use it inside a plain
[mlr3pipelines::GraphLearner](https://mlr3pipelines.mlr-org.com/reference/mlr_learners_graph.html)
via `ppl("targettrafo", ...)`, or wrap the forecaster itself with
`ppl("targettrafo", ...)` so all horizons are inverted together.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTargetTrafo`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html)
-\> `PipeOpTargetTrafoBoxCox`

## Methods

### Public methods

- [`PipeOpTargetTrafoBoxCox$new()`](#method-PipeOpTargetTrafoBoxCox-initialize)

- [`PipeOpTargetTrafoBoxCox$clone()`](#method-PipeOpTargetTrafoBoxCox-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpTargetTrafoBoxCox$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpTargetTrafoBoxCox$new(id = "fcst.targetboxcox", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.targetboxcox"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpTargetTrafoBoxCox$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpTargetTrafoBoxCox$clone(deep = FALSE)

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
  trafo_pipeop = po("fcst.targetboxcox")
))
flrn$train(task, split$train)
flrn$predict(task, split$test)
#> 
#> ── <PredictionFcst> for 29 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>       month row_ids truth response
#>  1958-08-01     116   505 409.4023
#>  1958-09-01     117   404 360.7524
#>  1958-10-01     118   359 303.4957
#>         ---     ---   ---      ---
#>  1960-10-01     142   461 360.4986
#>  1960-11-01     143   390 340.1683
#>  1960-12-01     144   432 356.7078
# }
```
