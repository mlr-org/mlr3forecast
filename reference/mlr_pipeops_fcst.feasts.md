# Time Series Feature Extraction (feasts)

Computes per-series summary features from the target variable via
[`fabletools::features()`](https://fabletools.tidyverts.org/reference/features.html)
with feature functions from the
[feasts](https://CRAN.R-project.org/package=feasts) package, and
broadcasts them as constant columns to every row of the corresponding
series. For an unkeyed task the features are broadcast to every row. For
a keyed task each key contributes one feature vector.

This is the [feasts](https://CRAN.R-project.org/package=feasts)
(tidyverts) counterpart of
[PipeOpFcstTsfeats](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.tsfeats.md).
Predicting on a key that was not seen during training is an error.

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
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.feasts", features = list(feasts::feat_acf))
out = po$train(list(task))[[1L]]
out$head()
#>    passengers passengers_feasts_acf1 passengers_feasts_acf10 passengers_feasts_diff1_acf1 passengers_feasts_diff1_acf10 passengers_feasts_diff2_acf1 passengers_feasts_diff2_acf10
#>         <num>                  <num>                   <num>                        <num>                         <num>                        <num>                         <num>
#> 1:        112              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 2:        118              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 3:        132              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 4:        129              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 5:        121              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 6:        135              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#>    passengers_feasts_season_acf1
#>                            <num>
#> 1:                      0.760395
#> 2:                      0.760395
#> 3:                      0.760395
#> 4:                      0.760395
#> 5:                      0.760395
#> 6:                      0.760395

# select features by tag via fabletools::feature_set() (requires feasts to be attached so its
# feature registry is populated)
library(feasts)
#> Loading required package: fabletools
features = fabletools::feature_set(pkgs = "feasts", tags = "autocorrelation")
po = po("fcst.feasts", features = features)
po$train(list(task))[[1L]]$head()
#>    passengers passengers_feasts_acf1 passengers_feasts_acf10 passengers_feasts_diff1_acf1 passengers_feasts_diff1_acf10 passengers_feasts_diff2_acf1 passengers_feasts_diff2_acf10
#>         <num>                  <num>                   <num>                        <num>                         <num>                        <num>                         <num>
#> 1:        112              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 2:        118              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 3:        132              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 4:        129              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 5:        121              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#> 6:        135              0.9480473                5.670087                    0.3028553                     0.4088376                   -0.1910059                     0.2507803
#>    passengers_feasts_season_acf1 passengers_feasts_pacf5 passengers_feasts_diff1_pacf5 passengers_feasts_diff2_pacf5 passengers_feasts_season_pacf
#>                            <num>                   <num>                         <num>                         <num>                         <num>
#> 1:                      0.760395               0.9670971                      1.176436                       1.15419                    -0.1354311
#> 2:                      0.760395               0.9670971                      1.176436                       1.15419                    -0.1354311
#> 3:                      0.760395               0.9670971                      1.176436                       1.15419                    -0.1354311
#> 4:                      0.760395               0.9670971                      1.176436                       1.15419                    -0.1354311
#> 5:                      0.760395               0.9670971                      1.176436                       1.15419                    -0.1354311
#> 6:                      0.760395               0.9670971                      1.176436                       1.15419                    -0.1354311
```
