# Direct Multi-Step Forecast Learner

Trains a separate model for each forecast horizon. For horizon `h` with
base lags `1:p`, model `h` uses lags `h:(h+p-1)`, so that at prediction
time only observed values are needed. Unlike
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md),
predictions do not feed back into subsequent steps (no error
accumulation).

Lag features are managed internally with horizon-shifted offsets via
`lags` – do not include any iterative feature PipeOp (property
`"fcst_iterative"`, e.g.
[PipeOpFcstLags](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.lags.md),
[PipeOpFcstRolling](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.rolling.md))
in the learner or graph. Such ops cannot yet be horizon-offset and would
leak future information for horizons \> 1, so they are rejected at
construction.

## Super class

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
`DirectForecaster`

## Active bindings

- `learner`:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html))  
  The base regression learner.

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The base lags.

- `horizons`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The forecast horizons.

- `param_set`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Set of hyperparameters.

- `marshaled`:

  (`logical(1)`)  
  Whether the learner's model is currently in marshaled form.

- `predict_type`:

  (`character(1)`)  
  Stores the currently active predict type.

## Methods

### Public methods

- [`DirectForecaster$new()`](#method-DirectForecaster-initialize)

- [`DirectForecaster$print()`](#method-DirectForecaster-print)

- [`DirectForecaster$marshal()`](#method-DirectForecaster-marshal)

- [`DirectForecaster$unmarshal()`](#method-DirectForecaster-unmarshal)

- [`DirectForecaster$clone()`](#method-DirectForecaster-clone)

Inherited methods

- [`mlr3::Learner$base_learner()`](https://mlr3.mlr-org.com/reference/Learner.html#method-base_learner)
- [`mlr3::Learner$configure()`](https://mlr3.mlr-org.com/reference/Learner.html#method-configure)
- [`mlr3::Learner$encapsulate()`](https://mlr3.mlr-org.com/reference/Learner.html#method-encapsulate)
- [`mlr3::Learner$format()`](https://mlr3.mlr-org.com/reference/Learner.html#method-format)
- [`mlr3::Learner$help()`](https://mlr3.mlr-org.com/reference/Learner.html#method-help)
- [`mlr3::Learner$predict()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict)
- [`mlr3::Learner$predict_newdata()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict_newdata)
- [`mlr3::Learner$reset()`](https://mlr3.mlr-org.com/reference/Learner.html#method-reset)
- [`mlr3::Learner$selected_features()`](https://mlr3.mlr-org.com/reference/Learner.html#method-selected_features)
- [`mlr3::Learner$train()`](https://mlr3.mlr-org.com/reference/Learner.html#method-train)

------------------------------------------------------------------------

### `DirectForecaster$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    DirectForecaster$new(
      learner,
      lags,
      horizons,
      id = NULL,
      param_vals = list(),
      predict_type = NULL
    )

#### Arguments

- `learner`:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html) \|
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  \|
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html))  
  A regression learner or a graph/PipeOp (without
  [PipeOpFcstLags](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.lags.md)).

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The base lag values. Exposed in `$param_set` as `lags`, so it can be
  tuned via
  [mlr3tuning::AutoTuner](https://mlr3tuning.mlr-org.com/reference/AutoTuner.html).

- `horizons`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  Either a single integer `H` (expanded to `1:H`) or an integer vector
  of specific horizons. One model is trained per horizon. At predict
  time each test row is routed to the model matching its step-distance
  from the end of training, so with specific horizons (e.g.
  `c(2L, 4L, 6L)`) the test set may only contain rows at those exact
  steps ahead.

- `id`:

  (`character(1)` \| `NULL`)  
  Identifier, default `NULL` (auto-generated from the learner id).

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Hyperparameter values applied to every horizon model. Per-horizon
  hyperparameters are not currently supported.

- `predict_type`:

  (`character(1)` \| `NULL`)  
  The predict type, default `NULL`.

------------------------------------------------------------------------

### `DirectForecaster$print()`

Printer.

#### Usage

    DirectForecaster$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### `DirectForecaster$marshal()`

Marshal the learner's model.

#### Usage

    DirectForecaster$marshal(...)

#### Arguments

- `...`:

  (any)  
  Additional arguments passed to
  [`mlr3::marshal_model()`](https://mlr3.mlr-org.com/reference/marshaling.html).

------------------------------------------------------------------------

### `DirectForecaster$unmarshal()`

Unmarshal the learner's model.

#### Usage

    DirectForecaster$unmarshal(...)

#### Arguments

- `...`:

  (any)  
  Additional arguments passed to
  [`mlr3::unmarshal_model()`](https://mlr3.mlr-org.com/reference/marshaling.html).

------------------------------------------------------------------------

### `DirectForecaster$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DirectForecaster$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)

task = tsk("airpassengers")
split = partition(task, ratio = 0.8)

# simple: one model per horizon
flrn = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test))
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

# or use the direct_forecaster() helper
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
