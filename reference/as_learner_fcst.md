# Convert to a Forecast Learner

Creates a
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md)
(recursive strategy) or
[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md)
(direct strategy), selected via `strategy`.

## Usage

``` r
as_learner_fcst(
  learner,
  lags = NULL,
  strategy = "recursive",
  horizons = NULL,
  ...
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
  The lag values to use for creating lag features.

- strategy:

  (`character(1)`)  
  Forecasting strategy. One of `"recursive"` (default) or `"direct"`.

- horizons:

  ([`integer()`](https://rdrr.io/r/base/integer.html) \| `NULL`)  
  Required when `strategy = "direct"`; must be `NULL` when
  `strategy = "recursive"`. A single integer `H` is expanded to `1:H`.

- ...:

  (any)  
  Additional arguments passed to
  [RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md)
  or
  [DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md).

## Value

[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md)
or
[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md).

## Examples

``` r
library(mlr3pipelines)

# recursive forecasting (default)
flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)

# recursive with a custom graph
graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
flrn = as_learner_fcst(graph)

# direct forecasting (one model per horizon)
flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3, strategy = "direct", horizons = 12)
```
