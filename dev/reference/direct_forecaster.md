# Create a Direct Forecast Learner

Function to create a
[DirectForecaster](https://mlr3forecast.mlr-org.com/dev/reference/DirectForecaster.md)
object. This is the recommended way to construct a direct forecaster. It
is a thin wrapper around `DirectForecaster$new()`.

A direct forecaster trains a separate regression model per forecast
horizon, so predictions never feed back into one another (no error
accumulation). For the recursive strategy (a single iterated model) see
[`recursive_forecaster()`](https://mlr3forecast.mlr-org.com/dev/reference/recursive_forecaster.md).

## Usage

``` r
direct_forecaster(
  learner,
  lags = NULL,
  horizons,
  id = NULL,
  param_vals = list(),
  predict_type = NULL,
  clone_graph = TRUE
)
```

## Arguments

- learner:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html) \|
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  \|
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html))  
  A regression learner or a graph/PipeOp. The model for horizon `h`
  shifts the graph's lag and rolling features `h - 1` steps into the
  past.

- lags:

  ([`integer()`](https://rdrr.io/r/base/integer.html) \| `NULL`)  
  The base lag values. If provided, `po("fcst.lags", lags = lags)` is
  added in front of `learner`, and its parameter `fcst.lags.lags` can be
  tuned via
  [mlr3tuning::AutoTuner](https://mlr3tuning.mlr-org.com/reference/AutoTuner.html).
  If `NULL`, the graph should contain its own lag or rolling features.

- horizons:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  Either a single integer `H` (expanded to `1:H`) or an integer vector
  of specific horizons. One model is trained per horizon.

- id:

  (`character(1)` \| `NULL`)  
  Identifier, default `NULL`, which uses the id of `learner` with the
  suffix `".direct"`.

- param_vals:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Hyperparameter values applied to every horizon model. Per-horizon
  hyperparameters are not currently supported.

- predict_type:

  (`character(1)` \| `NULL`)  
  The predict type, default `NULL`.

- clone_graph:

  (`logical(1)`)  
  Whether to clone the graph, default `TRUE`. If `lags` is provided, a
  new graph is built in any case.

## Value

[DirectForecaster](https://mlr3forecast.mlr-org.com/dev/reference/DirectForecaster.md).

## Examples

``` r
library(mlr3pipelines)

task = tsk("airpassengers")
split = partition(task, ratio = 0.8)

# one model per horizon
flrn = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test))
flrn$train(task, split$train)
flrn$predict(task, split$test)
#> 
#> ── <PredictionFcst> for 29 observations: ───────────────────────────────────────
#>       month row_ids truth response
#>  1958-08-01     116   505 391.9375
#>  1958-09-01     117   404 324.7500
#>  1958-10-01     118   359 306.0000
#>         ---     ---   ---      ---
#>  1960-10-01     142   461 368.6875
#>  1960-11-01     143   390 364.9333
#>  1960-12-01     144   432 362.3571

# graph: the same graph also works with recursive_forecaster()
graph = po("fcst.lags", lags = 1:3) %>>% po("fcst.rolling", window_sizes = 6L) %>>% lrn("regr.rpart")
flrn = direct_forecaster(graph, horizons = length(split$test))
```
