# Create a Recursive Forecast Learner

Function to create a
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md)
object. This is the recommended way to construct a recursive forecaster.
It is a thin wrapper around `RecursiveForecaster$new()`.

A recursive forecaster trains a single regression model and forecasts
iteratively one step ahead, feeding each prediction back as a
lag/rolling feature for the next step. For the direct strategy (one
model per horizon) see
[`direct_forecaster()`](https://mlr3forecast.mlr-org.com/reference/direct_forecaster.md).

## Usage

``` r
recursive_forecaster(
  learner,
  lags = NULL,
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
  A regression learner (when `lags` is provided) or a graph/PipeOp.

- lags:

  ([`integer()`](https://rdrr.io/r/base/integer.html) \| `NULL`)  
  The lag values to use for creating lag features. If provided,
  `learner` is wrapped with `po("fcst.lags", lags = lags)`. If `NULL`,
  `learner` must be a
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  or
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html).

- id:

  (`character(1)` \| `NULL`)  
  Identifier, default `NULL` (auto-generated).

- param_vals:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings.

- predict_type:

  (`character(1)` \| `NULL`)  
  The predict type, default `NULL`.

- clone_graph:

  (`logical(1)`)  
  Whether to clone the graph, default `TRUE`.

## Value

[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md).

## Examples

``` r
library(mlr3pipelines)

task = tsk("airpassengers")
split = partition(task, ratio = 0.8)

# simple: wrap a regression learner with lag features
flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
flrn$train(task, split$train)
flrn$predict(task, split$test)
#> 
#> ── <PredictionRegr> for 29 observations: ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  row_ids truth response      month
#>      116   505 391.9375 1958-08-01
#>      117   404 391.9375 1958-09-01
#>      118   359 391.9375 1958-10-01
#>      ---   ---      ---        ---
#>      142   461 391.9375 1960-10-01
#>      143   390 391.9375 1960-11-01
#>      144   432 391.9375 1960-12-01

# graph: custom preprocessing pipeline
graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
flrn = recursive_forecaster(graph)
```
