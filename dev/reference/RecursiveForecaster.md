# Recursive Forecast Learner

A [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html) for
iterative one-step-ahead forecasting: a single model is fit, then
applied recursively, feeding each prediction back as a lag/rolling
feature for the next step.

Can be constructed in two ways:

- **Simple**: `RecursiveForecaster$new(learner, lags = 1:3)` –
  internally builds `po("fcst.lags", lags = lags) %>>% learner`.

- **Graph**: `RecursiveForecaster$new(graph)` – takes an arbitrary
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  or
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html).

## Target transformations

A target transformation (e.g.
[mlr_pipeops_fcst.targetdiff](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.targetdiff.md),
[mlr3pipelines::PipeOpTargetMutate](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_targetmutate.html))
must *wrap* the forecaster, not be placed *inside* its graph. Wrap it
with
[mlr3pipelines::ppl](https://mlr3pipelines.mlr-org.com/reference/ppl.html)`("targettrafo")`
so the whole series is transformed once up front, the recursion runs
entirely on the transformed scale, and predictions are inverted once at
the end:

    flrn = as_learner(ppl("targettrafo",
      graph = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:12),
      trafo_pipeop = po("fcst.targetdiff", lag = 1L)
    ))
    flrn$train(task, split$train)
    flrn$predict(task, split$test)  # predictions are on the original scale

Placing a
[mlr3pipelines::PipeOpTargetTrafo](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html)
*inside* the graph is not supported and is rejected at construction.

## Prediction uncertainty

Only the point forecast is fed back between steps, so `se`/`distr`
uncertainty does not accumulate across horizons and intervals are too
narrow for `h > 1`. For calibrated multi-step intervals, prefer
[DirectForecaster](https://mlr3forecast.mlr-org.com/dev/reference/DirectForecaster.md).

## Validation and internal tuning

If the wrapped graph contains a learner with the `"validation"`
property, the forecaster supports validation and internal tuning as
well. Configure it with
[`mlr3::set_validate()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html),
which sets the forecaster's `$validate` field and routes the validation
data to the graph's base learner. A numeric ratio is split
chronologically per key (via
[`partition()`](https://mlr3.mlr-org.com/reference/partition.html)), so
the validation set is always the most recent fraction of each series.
Note that the validation scores measure one-step-ahead (teacher-forced)
accuracy, not recursive multi-step accuracy.

## Super class

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
`RecursiveForecaster`

## Active bindings

- `learner`:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html))  
  The base regression learner.

- `native_model`:

  (any)  
  The fitted model.

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html) \| `NULL`)  
  The lags used, or `NULL` if no
  [PipeOpFcstLags](https://mlr3forecast.mlr-org.com/dev/reference/mlr_pipeops_fcst.lags.md)
  is in the graph.

- `param_set`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Set of hyperparameters.

- `marshaled`:

  (`logical(1)`)  
  Whether the learner's model is currently in marshaled form.

- `validate`:

  (`numeric(1)` \| `"predefined"` \| `"test"` \| `NULL`)  
  How to construct the internal validation data. Use
  [`mlr3::set_validate()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)
  to also configure the wrapped graph.

- `internal_valid_scores`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  The internal validation scores extracted from the wrapped graph, or
  `NULL` if no validation was done.

- `internal_tuned_values`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  The internally tuned values extracted from the wrapped graph, or
  `NULL` if no internal tuning was done.

- `predict_type`:

  (`character(1)`)  
  Stores the currently active predict type.

## Methods

### Public methods

- [`RecursiveForecaster$new()`](#method-RecursiveForecaster-initialize)

- [`RecursiveForecaster$print()`](#method-RecursiveForecaster-print)

- [`RecursiveForecaster$marshal()`](#method-RecursiveForecaster-marshal)

- [`RecursiveForecaster$unmarshal()`](#method-RecursiveForecaster-unmarshal)

- [`RecursiveForecaster$importance()`](#method-RecursiveForecaster-importance)

- [`RecursiveForecaster$selected_features()`](#method-RecursiveForecaster-selected_features)

- [`RecursiveForecaster$oob_error()`](#method-RecursiveForecaster-oob_error)

- [`RecursiveForecaster$clone()`](#method-RecursiveForecaster-clone)

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

### `RecursiveForecaster$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    RecursiveForecaster$new(
      learner,
      lags = NULL,
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
  A regression learner (when `lags` is provided) or a graph/PipeOp.

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html) \| `NULL`)  
  The lag values to use for creating lag features. If provided,
  `learner` is wrapped with `po("fcst.lags", lags = lags)`. If `NULL`,
  `learner` must be a
  [mlr3pipelines::Graph](https://mlr3pipelines.mlr-org.com/reference/Graph.html)
  or
  [mlr3pipelines::PipeOp](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html).

- `id`:

  (`character(1)` \| `NULL`)  
  Identifier, default `NULL` (auto-generated).

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings.

- `predict_type`:

  (`character(1)` \| `NULL`)  
  The predict type, default `NULL`.

- `clone_graph`:

  (`logical(1)`)  
  Whether to clone the graph, default `TRUE`.

------------------------------------------------------------------------

### `RecursiveForecaster$print()`

Printer.

#### Usage

    RecursiveForecaster$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### `RecursiveForecaster$marshal()`

Marshal the learner's model.

#### Usage

    RecursiveForecaster$marshal(...)

#### Arguments

- `...`:

  (any)  
  Additional arguments passed to
  [`mlr3::marshal_model()`](https://mlr3.mlr-org.com/reference/marshaling.html).

------------------------------------------------------------------------

### `RecursiveForecaster$unmarshal()`

Unmarshal the learner's model.

#### Usage

    RecursiveForecaster$unmarshal(...)

#### Arguments

- `...`:

  (any)  
  Additional arguments passed to
  [`mlr3::unmarshal_model()`](https://mlr3.mlr-org.com/reference/marshaling.html).

------------------------------------------------------------------------

### `RecursiveForecaster$importance()`

The importance scores of the base learner, if it supports them.

#### Usage

    RecursiveForecaster$importance()

#### Returns

Named [`numeric()`](https://rdrr.io/r/base/numeric.html).

------------------------------------------------------------------------

### `RecursiveForecaster$selected_features()`

The selected features of the base learner, if it supports them.

#### Usage

    RecursiveForecaster$selected_features()

#### Returns

[`character()`](https://rdrr.io/r/base/character.html).

------------------------------------------------------------------------

### `RecursiveForecaster$oob_error()`

The out-of-bag error of the base learner, if it supports it.

#### Usage

    RecursiveForecaster$oob_error()

#### Returns

`numeric(1)`.

------------------------------------------------------------------------

### `RecursiveForecaster$clone()`

The objects of this class are cloneable with this method.

#### Usage

    RecursiveForecaster$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)

task = tsk("airpassengers")
flrn = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
split = partition(task, ratio = 0.8)
flrn$train(task, split$train)
flrn$predict(task, split$test)
#> 
#> ── <PredictionFcst> for 29 observations: ───────────────────────────────────────
#>       month row_ids truth response
#>  1958-08-01     116   505 391.9375
#>  1958-09-01     117   404 391.9375
#>  1958-10-01     118   359 391.9375
#>         ---     ---   ---      ---
#>  1960-10-01     142   461 391.9375
#>  1960-11-01     143   390 391.9375
#>  1960-12-01     144   432 391.9375

# graph: custom preprocessing pipeline
graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
flrn = RecursiveForecaster$new(graph)
flrn$train(task, split$train)
flrn$predict(task, split$test)
#> 
#> ── <PredictionFcst> for 29 observations: ───────────────────────────────────────
#>       month row_ids truth response
#>  1958-08-01     116   505 391.9375
#>  1958-09-01     117   404 391.9375
#>  1958-10-01     118   359 391.9375
#>         ---     ---   ---      ---
#>  1960-10-01     142   461 391.9375
#>  1960-11-01     143   390 391.9375
#>  1960-12-01     144   432 391.9375
```
