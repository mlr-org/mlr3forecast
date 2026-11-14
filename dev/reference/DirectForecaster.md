# Direct Multi-Step Forecast Learner

Trains a separate model for each forecast horizon. Unlike
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md),
predictions do not feed back into subsequent steps (no error
accumulation).

Can be constructed in two ways, like
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md):

- **Simple**: `DirectForecaster$new(learner, lags = 1:3, horizons = 12)`
  – internally builds `po("fcst.lags", lags = lags) %>>% learner`.

- **Graph**: `DirectForecaster$new(graph, horizons = 12)` – takes a
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  or
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
  that creates its own lag or rolling features, so the same graph works
  with both forecasters.

## Iterative features

The model for horizon `h` is trained on a copy of the graph in which
every PipeOp with the `"fcst_iterative"` property, e.g.
[PipeOpFcstLags](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.lags.md)
or
[PipeOpFcstRolling](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.rolling.md),
is shifted `h - 1` steps into the past via its `$shift()` method. For
example, base lags `1:3` become lags `h:(h + 2)`, so at prediction time
only observed values are needed. Tune the base values via the PipeOp's
parameters, e.g. `fcst.lags.lags`. Only the last `$lookback`
observations of each series are kept for prediction, or all of them for
an expanding window. At predict time the graph is evaluated with the
trained state of each horizon, so iterative PipeOps must store the
settings their predict step needs in their state.

## Wrapped learner

`$graph` is the wrapped graph and `$base_learner()` its base learner,
like for
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md).
Both are the untrained templates shared by all horizons, the trained
graph of each horizon is in `$graph_model`.

## Super class

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
`DirectForecaster`

## Active bindings

- `learner`:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html))  
  The untrained base regression learner of the graph, the same as
  `$base_learner()`.

- `graph`:

  ([mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html))  
  The wrapped graph, without the per-horizon shift. Read-only.

- `quantiles`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Numeric vector of probabilities to be used while predicting quantiles.
  Elements must be between 0 and 1, not missing and provided in
  ascending order. If only one quantile is provided, it is used as
  response. Otherwise, set `$quantile_response` to specify the response
  quantile. Set to `NULL` to reset both `$quantiles` and
  `$quantile_response`.

- `quantile_response`:

  (`numeric(1)`)  
  The quantile to be used as response.

- `graph_model`:

  ([mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  \| named [`list()`](https://rdrr.io/r/base/list.html))  
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  that is being wrapped. After `$train()`, a named list with one trained
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  per horizon (`h1`, `h2`, ...). Read-only.

- `native_model`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  The fitted models.

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html) \| `NULL`)  
  The lags of the first
  [PipeOpFcstLags](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.lags.md)
  in the graph, which the model for horizon `h` shifts by `h - 1`, or
  `NULL` if there is none.

- `horizons`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The forecast horizons.

- `param_set`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Set of hyperparameters.

- `hash`:

  (`character(1)`)  
  Hash (unique identifier) for this object.

- `phash`:

  (`character(1)`)  
  Hash (unique identifier) for this partial object, excluding some
  components which are varied systematically during tuning (parameter
  values).

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

- [`DirectForecaster$predict_newdata_fast()`](#method-DirectForecaster-predict_newdata_fast)

- [`DirectForecaster$marshal()`](#method-DirectForecaster-marshal)

- [`DirectForecaster$unmarshal()`](#method-DirectForecaster-unmarshal)

- [`DirectForecaster$importance()`](#method-DirectForecaster-importance)

- [`DirectForecaster$selected_features()`](#method-DirectForecaster-selected_features)

- [`DirectForecaster$oob_error()`](#method-DirectForecaster-oob_error)

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
- [`mlr3::Learner$train()`](https://mlr3.mlr-org.com/reference/Learner.html#method-train)

------------------------------------------------------------------------

### `DirectForecaster$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    DirectForecaster$new(
      learner,
      lags = NULL,
      horizons,
      id = NULL,
      param_vals = list(),
      predict_type = NULL,
      clone_graph = TRUE
    )

#### Arguments

- `learner`:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html) \|
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  \|
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html))  
  A regression learner or a graph/PipeOp.

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html) \| `NULL`)  
  The base lag values. If provided, `po("fcst.lags", lags = lags)` is
  added in front of `learner`, and its parameter `fcst.lags.lags` can be
  tuned via
  [mlr3tuning::AutoTuner](https://mlr3tuning.mlr-org.com/reference/AutoTuner.html).
  If `NULL`, the graph should contain its own lag or rolling features.

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
  Identifier, default `NULL`, which uses the id of `learner` with the
  suffix `".direct"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Hyperparameter values applied to every horizon model. Per-horizon
  hyperparameters are not currently supported.

- `predict_type`:

  (`character(1)` \| `NULL`)  
  The predict type, default `NULL`.

- `clone_graph`:

  (`logical(1)`)  
  Whether to clone the graph, default `TRUE`. If `lags` is provided, a
  new graph is built in any case.

------------------------------------------------------------------------

### `DirectForecaster$print()`

Printer.

#### Usage

    DirectForecaster$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### `DirectForecaster$predict_newdata_fast()`

Not supported, use `$predict_newdata()` or
[`forecast()`](https://generics.r-lib.org/reference/forecast.html)
instead.

#### Usage

    DirectForecaster$predict_newdata_fast(newdata, task = NULL)

#### Arguments

- `newdata`:

  (ignored).

- `task`:

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

### `DirectForecaster$importance()`

The importance scores of the base learner of each horizon model, if it
supports them. Unlike
[mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)'s
`$importance()` this returns one vector per horizon, so the
`"importance"` property is deliberately not advertised.

#### Usage

    DirectForecaster$importance()

#### Returns

Named [`list()`](https://rdrr.io/r/base/list.html) of named
[`numeric()`](https://rdrr.io/r/base/numeric.html), one element per
horizon (`h1`, `h2`, ...).

------------------------------------------------------------------------

### `DirectForecaster$selected_features()`

The selected features of the base learner of each horizon model, if it
supports them.

#### Usage

    DirectForecaster$selected_features()

#### Returns

Named [`list()`](https://rdrr.io/r/base/list.html) of
[`character()`](https://rdrr.io/r/base/character.html), one element per
horizon (`h1`, `h2`, ...).

------------------------------------------------------------------------

### `DirectForecaster$oob_error()`

The out-of-bag error of the base learner of each horizon model, if it
supports it.

#### Usage

    DirectForecaster$oob_error()

#### Returns

Named [`list()`](https://rdrr.io/r/base/list.html) of `numeric(1)`, one
element per horizon (`h1`, `h2`, ...).

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
# \donttest{
library(mlr3pipelines)

task = tsk("airpassengers")
split = partition(task, ratio = 0.8)

# simple: one model per horizon
flrn = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test))
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

# graph: lag and rolling features, shifted per horizon
graph = po("fcst.lags", lags = 1:3) %>>%
  po("fcst.rolling", window_sizes = 6L) %>>%
  lrn("regr.rpart")
flrn = DirectForecaster$new(graph, horizons = length(split$test))
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
#>  1960-12-01     144   432 338.0000
# }
```
