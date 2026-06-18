# Create a Direct Forecast Learner

Function to create a
[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md)
object. This is the recommended way to construct a direct forecaster; it
is a thin wrapper around `DirectForecaster$new()`.

A direct forecaster trains a separate regression model per forecast
horizon, so predictions never feed back into one another (no error
accumulation). For the recursive strategy (a single iterated model) see
[`recursive_forecaster()`](https://mlr3forecast.mlr-org.com/reference/recursive_forecaster.md).

## Usage

``` r
direct_forecaster(
  learner,
  lags,
  horizons,
  id = NULL,
  param_vals = list(),
  predict_type = NULL
)
```

## Arguments

- learner:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html) \|
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  \|
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html))  
  A regression learner or a graph/PipeOp (without
  [PipeOpFcstLags](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.lags.md)).

- lags:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The base lag values. Exposed in `$param_set` as `lags`, so it can be
  tuned via
  [mlr3tuning::AutoTuner](https://mlr3tuning.mlr-org.com/reference/AutoTuner.html).

- horizons:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  Either a single integer `H` (expanded to `1:H`) or an integer vector
  of specific horizons. One model is trained per horizon.

- id:

  (`character(1)` \| `NULL`)  
  Identifier, default `NULL` (auto-generated from the learner id).

- param_vals:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Hyperparameter values applied to every horizon model. Per-horizon
  hyperparameters are not currently supported.

- predict_type:

  (`character(1)` \| `NULL`)  
  The predict type, default `NULL`.

## Value

[DirectForecaster](https://mlr3forecast.mlr-org.com/reference/DirectForecaster.md).

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
#> ── <PredictionRegr> for 29 observations: ───────────────────────────────────────
#>  row_ids truth response      month
#>      116   505 391.9375 1958-08-01
#>      117   404 324.7500 1958-09-01
#>      118   359 306.0000 1958-10-01
#>      ---   ---      ---        ---
#>      142   461 368.6875 1960-10-01
#>      143   390 364.9333 1960-11-01
#>      144   432 362.3571 1960-12-01
```
