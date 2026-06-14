# Time Series Feature Extraction (feasts)

Computes per-series summary features from the target variable via
[`fabletools::features()`](https://fabletools.tidyverts.org/reference/features.html)
with feature functions from the
[feasts](https://CRAN.R-project.org/package=feasts) package, and
broadcasts them as constant columns to every row of the corresponding
series. For an unkeyed task the features are broadcast to every row; for
a keyed task each key contributes one feature vector.

This is the [feasts](https://CRAN.R-project.org/package=feasts)
(tidyverts) counterpart of
[PipeOpFcstTsfeats](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.tsfeats.md),
which uses the
[tsfeatures](https://CRAN.R-project.org/package=tsfeatures) package. The
order column is mapped to an appropriate
[tsibble](https://CRAN.R-project.org/package=tsibble) index
(`yearmonth`/`yearquarter`/`yearweek` for the respective frequencies,
otherwise used as-is) so that the seasonal period is inferred correctly.

Features are cached in the state at train time and reused at predict
time. Predicting on a key that was not seen during training is an error.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTaskPreproc](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as:

- `features` :: [`list()`](https://rdrr.io/r/base/list.html)  
  A list of [feasts](https://CRAN.R-project.org/package=feasts) feature
  functions (e.g.
  [feasts::feat_acf](https://feasts.tidyverts.org/reference/feat_acf.html),
  [feasts::feat_stl](https://feasts.tidyverts.org/reference/feat_stl.html))
  or a
  [`fabletools::feature_set()`](https://fabletools.tidyverts.org/reference/feature_set.html).
  Default `list(feasts::feat_acf, feasts::feat_stl)`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFcstFeasts`

## Methods

### Public methods

- [`PipeOpFcstFeasts$new()`](#method-PipeOpFcstFeasts-initialize)

- [`PipeOpFcstFeasts$clone()`](#method-PipeOpFcstFeasts-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstFeasts$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstFeasts$new(id = "fcst.feasts", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.feasts"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstFeasts$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstFeasts$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.feasts", features = list(feasts::feat_acf))
out = po$train(list(task))[[1L]]
out$head()

# select features by tag via fabletools::feature_set() (requires feasts to be attached so its
# feature registry is populated)
library(feasts)
po = po("fcst.feasts", features = fabletools::feature_set(pkgs = "feasts", tags = "autocorrelation"))
po$train(list(task))[[1L]]$head()
} # }
```
