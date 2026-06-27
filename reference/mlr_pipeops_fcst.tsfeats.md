# Time Series Feature Extraction

Computes per-series summary features from the target variable via
[`tsfeatures::tsfeatures()`](http://pkg.robjhyndman.com/tsfeatures/reference/tsfeatures.md)
and broadcasts them as constant columns to every row of the
corresponding series. For an unkeyed task the features are broadcast to
every row. For a keyed task each key contributes one feature vector.

Features are cached in the state at train time and reused at predict
time. Predicting on a key that was not seen during training is an error.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTaskPreproc](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as:

- `features` :: [`character()`](https://rdrr.io/r/base/character.html)  
  Function names from the `tsfeatures` namespace that return numeric
  feature vectors. Default
  `c("frequency", "stl_features", "entropy", "acf_features")`.

- `scale` :: `logical(1)`  
  If `TRUE`, scale each series to mean 0 and sd 1 before feature
  extraction. Default `TRUE`.

- `trim` :: `logical(1)`  
  If `TRUE`, trim values outside `±trim_amount` before feature
  extraction. Default `FALSE`.

- `trim_amount` :: `numeric(1)`  
  Trimming threshold. Default `0.1`.

- `parallel` :: `logical(1)`  
  If `TRUE`, compute features in parallel via a
  [`future::plan()`](https://future.futureverse.org/reference/plan.html).
  Default `FALSE`.

- `multiprocess` :: `function`  
  Function from the `future` package used when `parallel = TRUE`.
  Default
  [`future::multisession()`](https://future.futureverse.org/reference/multisession.html).

- `na.action` :: `function`  
  Missing-value handler. Default
  [`stats::na.pass()`](https://rdrr.io/r/stats/na.fail.html).

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFcstTsfeats`

## Methods

### Public methods

- [`PipeOpFcstTsfeats$new()`](#method-PipeOpFcstTsfeats-initialize)

- [`PipeOpFcstTsfeats$clone()`](#method-PipeOpFcstTsfeats-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstTsfeats$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstTsfeats$new(id = "fcst.tsfeats", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.tsfeats"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstTsfeats$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstTsfeats$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.tsfeats", features = c("entropy", "acf_features"))
out = po$train(list(task))[[1L]]
out$head()
#>    passengers passengers_tsf_entropy passengers_tsf_x_acf1 passengers_tsf_x_acf10 passengers_tsf_diff1_acf1 passengers_tsf_diff1_acf10 passengers_tsf_diff2_acf1
#>         <num>                  <num>                 <num>                  <num>                     <num>                      <num>                     <num>
#> 1:        112              0.2961049             0.9480473               5.670087                 0.3028553                  0.4088376                -0.1910059
#> 2:        118              0.2961049             0.9480473               5.670087                 0.3028553                  0.4088376                -0.1910059
#> 3:        132              0.2961049             0.9480473               5.670087                 0.3028553                  0.4088376                -0.1910059
#> 4:        129              0.2961049             0.9480473               5.670087                 0.3028553                  0.4088376                -0.1910059
#> 5:        121              0.2961049             0.9480473               5.670087                 0.3028553                  0.4088376                -0.1910059
#> 6:        135              0.2961049             0.9480473               5.670087                 0.3028553                  0.4088376                -0.1910059
#>    passengers_tsf_diff2_acf10 passengers_tsf_seas_acf1
#>                         <num>                    <num>
#> 1:                  0.2507803                 0.760395
#> 2:                  0.2507803                 0.760395
#> 3:                  0.2507803                 0.760395
#> 4:                  0.2507803                 0.760395
#> 5:                  0.2507803                 0.760395
#> 6:                  0.2507803                 0.760395
```
