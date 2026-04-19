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

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTargetTrafo`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTargetTrafo.html)
-\> `PipeOpTargetTrafoDifference`

## Methods

### Public methods

- [`PipeOpTargetTrafoDifference$new()`](#method-PipeOpTargetTrafoDifference-new)

- [`PipeOpTargetTrafoDifference$clone()`](#method-PipeOpTargetTrafoDifference-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

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

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpTargetTrafoDifference$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
