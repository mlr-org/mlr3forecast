# Time Series Feature Extraction (catch22)

Computes the 22 (or 24) canonical time-series characteristics of the
target variable via
[`Rcatch22::catch22_all()`](https://rdrr.io/pkg/Rcatch22/man/catch22_all.html),
and broadcasts them as constant columns to every row of the
corresponding series. For an unkeyed task the features are broadcast to
every row; for a keyed task each key contributes one feature vector.

The catch22 set is a low-redundancy subset of the hctsa features
selected for time-series classification performance and is computed in
C, making it considerably faster than
[PipeOpFcstTsfeats](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.tsfeats.md)
and
[PipeOpFcstFeasts](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.feasts.md).
The features are computed on the ordered target vector and are agnostic
to the seasonal period, so unlike the other two extractors they contain
no explicit seasonal/trend features.

Features are cached in the state at train time and reused at predict
time. Predicting on a key that was not seen during training is an error.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTaskPreproc](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as:

- `catch24` :: `logical(1)`  
  If `TRUE`, additionally compute the mean and standard deviation (the
  catch24 set). Default `FALSE`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFcstCatch22`

## Methods

### Public methods

- [`PipeOpFcstCatch22$new()`](#method-PipeOpFcstCatch22-initialize)

- [`PipeOpFcstCatch22$clone()`](#method-PipeOpFcstCatch22-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstCatch22$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstCatch22$new(id = "fcst.catch22", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.catch22"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstCatch22$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstCatch22$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.catch22")
out = po$train(list(task))[[1L]]
out$head()
} # }
```
