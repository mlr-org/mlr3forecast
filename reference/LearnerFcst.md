# Forecast Learner

This Learner specializes
[mlr3::LearnerRegr](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
for forecast problems:

- `task_type` is set to `"fcst"`.

- Creates
  [mlr3::Prediction](https://mlr3.mlr-org.com/reference/Prediction.html)s
  of class
  [mlr3::PredictionRegr](https://mlr3.mlr-org.com/reference/PredictionRegr.html).

- Possible values for `predict_types` are:

  - `"response"`: Predicts a numeric response for each observation in
    the test set.

  - `"se"`: Predicts the standard error for each value of response for
    each observation in the test set.

  - `"distr"`: Probability distribution as `VectorDistribution` object
    (requires package `distr6`, available via repository
    <https://raphaels1.r-universe.dev>).

Predefined learners can be found in the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html).

## See also

- Chapter in the [mlr3book](https://mlr3book.mlr-org.com/):
  <https://mlr3book.mlr-org.com/chapters/chapter2/data_and_basic_modeling.html#sec-learners>

- Package
  [mlr3learners](https://CRAN.R-project.org/package=mlr3learners) for a
  solid collection of essential learners.

- Package
  [mlr3extralearners](https://github.com/mlr-org/mlr3extralearners) for
  more learners.

- [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of [Learners](https://mlr3.mlr-org.com/reference/Learner.html):
  [mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)

- `as.data.table(mlr_learners)` for a table of available
  [Learners](https://mlr3.mlr-org.com/reference/Learner.html) in the
  running session (depending on the loaded packages).

- [mlr3pipelines](https://CRAN.R-project.org/package=mlr3pipelines) to
  combine learners with pre- and postprocessing steps.

- Package [mlr3viz](https://CRAN.R-project.org/package=mlr3viz) for some
  generic visualizations.

- Extension packages for additional task types:

  - [mlr3proba](https://CRAN.R-project.org/package=mlr3proba) for
    probabilistic supervised regression and survival analysis.

  - [mlr3cluster](https://CRAN.R-project.org/package=mlr3cluster) for
    unsupervised clustering.

- [mlr3tuning](https://CRAN.R-project.org/package=mlr3tuning) for tuning
  of hyperparameters,
  [mlr3tuningspaces](https://CRAN.R-project.org/package=mlr3tuningspaces)
  for established default tuning spaces.

Other Learner:
[`mlr_learners_fcst.adam`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.adam.md),
[`mlr_learners_fcst.arfima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.arfima.md),
[`mlr_learners_fcst.arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.arima.md),
[`mlr_learners_fcst.auto_adam`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_adam.md),
[`mlr_learners_fcst.auto_arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_arima.md),
[`mlr_learners_fcst.auto_ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_ces.md),
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.croston`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.croston.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.theta.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\> `LearnerFcst`

## Methods

### Public methods

- [`LearnerFcst$new()`](#method-LearnerFcst-new)

- [`LearnerFcst$clone()`](#method-LearnerFcst-clone)

Inherited methods

- [`mlr3::Learner$base_learner()`](https://mlr3.mlr-org.com/reference/Learner.html#method-base_learner)
- [`mlr3::Learner$configure()`](https://mlr3.mlr-org.com/reference/Learner.html#method-configure)
- [`mlr3::Learner$encapsulate()`](https://mlr3.mlr-org.com/reference/Learner.html#method-encapsulate)
- [`mlr3::Learner$format()`](https://mlr3.mlr-org.com/reference/Learner.html#method-format)
- [`mlr3::Learner$help()`](https://mlr3.mlr-org.com/reference/Learner.html#method-help)
- [`mlr3::Learner$predict()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict)
- [`mlr3::Learner$predict_newdata()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict_newdata)
- [`mlr3::Learner$print()`](https://mlr3.mlr-org.com/reference/Learner.html#method-print)
- [`mlr3::Learner$reset()`](https://mlr3.mlr-org.com/reference/Learner.html#method-reset)
- [`mlr3::Learner$selected_features()`](https://mlr3.mlr-org.com/reference/Learner.html#method-selected_features)
- [`mlr3::Learner$train()`](https://mlr3.mlr-org.com/reference/Learner.html#method-train)
- [`mlr3::LearnerRegr$predict_newdata_fast()`](https://mlr3.mlr-org.com/reference/LearnerRegr.html#method-predict_newdata_fast)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    LearnerFcst$new(
      id,
      param_set = ps(),
      predict_types = "response",
      feature_types = character(),
      properties = character(),
      packages = character(),
      label = NA_character_,
      man = NA_character_
    )

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier for the new instance.

- `param_set`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Set of hyperparameters.

- `predict_types`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Supported predict types. Must be a subset of
  [`mlr_reflections$learner_predict_types`](https://mlr3.mlr-org.com/reference/mlr_reflections.html).

- `feature_types`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Feature types the learner operates on. Must be a subset of
  [`mlr_reflections$task_feature_types`](https://mlr3.mlr-org.com/reference/mlr_reflections.html).

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of properties of the
  [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html). Must
  be a subset of
  [`mlr_reflections$learner_properties`](https://mlr3.mlr-org.com/reference/mlr_reflections.html).
  The following properties are currently standardized and understood by
  learners in [mlr3](https://CRAN.R-project.org/package=mlr3):

  - `"missings"`: The learner can handle missing values in the data.

  - `"weights"`: The learner supports observation weights.

  - `"importance"`: The learner supports extraction of importance
    scores, i.e. comes with an `$importance()` extractor function (see
    section on optional extractors in
    [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)).

  - `"selected_features"`: The learner supports extraction of the set of
    selected features, i.e. comes with a `$selected_features()`
    extractor function (see section on optional extractors in
    [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)).

  - `"oob_error"`: The learner supports extraction of estimated out of
    bag error, i.e. comes with a `oob_error()` extractor function (see
    section on optional extractors in
    [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)).

  - `"validation"`: The learner can use a validation task during
    training.

  - `"internal_tuning"`: The learner is able to internally optimize
    hyperparameters (those are also tagged with `"internal_tuning"`).

  - `"marshal"`: To save learners with this property, you need to call
    `$marshal()` first. If a learner is in a marshaled state, you call
    first need to call `$unmarshal()` to use its model, e.g. for
    prediction.

- `packages`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of required packages. A warning is signaled by the constructor if
  at least one of the packages is not installed, but loaded (not
  attached) later on-demand via
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html).

- `label`:

  (`character(1)`)  
  Label for the new instance.

- `man`:

  (`character(1)`)  
  String in the format `[pkg]::[topic]` pointing to a manual page for
  this object. The referenced help package can be opened via method
  `$help()`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcst$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# get all forecast learners from mlr_learners:
lrns = mlr_learners$mget(mlr_learners$keys("^fcst"))
names(lrns)
#>  [1] "fcst.adam"       "fcst.arfima"     "fcst.arima"      "fcst.auto_adam" 
#>  [5] "fcst.auto_arima" "fcst.auto_ces"   "fcst.bats"       "fcst.ces"       
#>  [9] "fcst.croston"    "fcst.ets"        "fcst.nnetar"     "fcst.spline"    
#> [13] "fcst.tbats"      "fcst.theta"     

# get a specific learner from mlr_learners:
mlr_learners$get("fcst.ets")
#> 
#> ── <LearnerFcstEts> (fcst.ets): ETS ────────────────────────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and forecast
#> • Predict Types: [response] and quantiles
#> • Feature Types: logical, integer, numeric, character, factor, ordered,
#> POSIXct, and Date
#> • Encapsulation: none (fallback: -)
#> • Properties: featureless and missings
#> • Other settings: use_weights = 'error'
lrn("fcst.auto_arima")
#> 
#> ── <LearnerFcstAutoArima> (fcst.auto_arima): Auto ARIMA ────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and forecast
#> • Predict Types: [response] and quantiles
#> • Feature Types: logical, integer, and numeric
#> • Encapsulation: none (fallback: -)
#> • Properties: exogenous, featureless, and missings
#> • Other settings: use_weights = 'error'
```
