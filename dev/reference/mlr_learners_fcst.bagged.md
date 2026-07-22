# Bagged Model Forecast Learner

Bootstrap-aggregated forecasts. The series is resampled via the
Box-Cox/Loess moving block bootstrap of Bergmeir, Hyndman, and Benítez
and `fn` is fit on each replicate. The forecast averages across the
ensemble. Calls
[`forecast::baggedModel()`](https://pkg.robjhyndman.com/forecast/reference/baggedModel.html)
from package [forecast](https://CRAN.R-project.org/package=forecast).

`fn` is the model-fitting function applied to each bootstrap replicate
(defaults to
[`forecast::ets()`](https://pkg.robjhyndman.com/forecast/reference/ets.html)).
Any function returning an object compatible with
[`forecast::forecast()`](https://generics.r-lib.org/reference/forecast.html)
may be passed, e.g.
[`forecast::auto.arima()`](https://pkg.robjhyndman.com/forecast/reference/auto.arima.html)
or
[`forecast::Arima()`](https://pkg.robjhyndman.com/forecast/reference/Arima.html)
with fixed orders via a wrapper. The number of bootstrap replicates is
controlled by `num`, and `block_size` configures the moving block length
in
[`forecast::bld.mbb.bootstrap()`](https://pkg.robjhyndman.com/forecast/reference/bld.mbb.bootstrap.html).
Prediction intervals from
[`forecast::forecast.baggedModel()`](https://pkg.robjhyndman.com/forecast/reference/forecast.baggedModel.html)
are the empirical bootstrap range (not configurable by `level`), so only
`"response"` is offered as a `predict_type`.

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.bagged")
    lrn("fcst.bagged")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”

- Feature Types: “logical”, “integer”, “numeric”, “character”, “factor”,
  “ordered”, “POSIXct”, “Date”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [forecast](https://CRAN.R-project.org/package=forecast)

## Parameters

|            |         |         |                  |
|------------|---------|---------|------------------|
| Id         | Type    | Default | Range            |
| fn         | untyped | \-      | \-               |
| num        | integer | 100     | \\\[1, \infty)\\ |
| block_size | integer | NULL    | \\\[1, \infty)\\ |

## References

Bergmeir C, Hyndman RJ, Benítez JM (2016). “Bagging exponential
smoothing methods using STL decomposition and Box-Cox transformation.”
*International Journal of Forecasting*, **32**(2), 303–312.
[doi:10.1016/j.ijforecast.2015.07.002](https://doi.org/10.1016/j.ijforecast.2015.07.002)
.

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
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcst.md),
[`mlr_learners_fcst.adam`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.adam.md),
[`mlr_learners_fcst.arfima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.arfima.md),
[`mlr_learners_fcst.arima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.arima.md),
[`mlr_learners_fcst.auto_adam`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_adam.md),
[`mlr_learners_fcst.auto_arima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_arima.md),
[`mlr_learners_fcst.auto_ces`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_ces.md),
[`mlr_learners_fcst.auto_gum`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_gum.md),
[`mlr_learners_fcst.auto_msarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_msarima.md),
[`mlr_learners_fcst.auto_ssarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_ssarima.md),
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.croston`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.croston.md),
[`mlr_learners_fcst.elm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.elm.md),
[`mlr_learners_fcst.es`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.es.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.gum`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.gum.md),
[`mlr_learners_fcst.holt_winters`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.holt_winters.md),
[`mlr_learners_fcst.mean`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mean.md),
[`mlr_learners_fcst.mlp`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mlp.md),
[`mlr_learners_fcst.msarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.msarima.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.prophet`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.prophet.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.rlgt`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.rlgt.md),
[`mlr_learners_fcst.sma`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.sma.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.ssarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ssarima.md),
[`mlr_learners_fcst.stlm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.stlm.md),
[`mlr_learners_fcst.struct_ts`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.struct_ts.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.theta.md),
[`mlr_learners_fcst.tscount`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tscount.md),
[`mlr_learners_fcst.tslm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tslm.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcst.md)
-\>
[`LearnerFcstForecast`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcstForecast.md)
-\> `LearnerFcstBaggedModel`

## Methods

### Public methods

- [`LearnerFcstBaggedModel$new()`](#method-LearnerFcstBaggedModel-initialize)

- [`LearnerFcstBaggedModel$clone()`](#method-LearnerFcstBaggedModel-clone)

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

### `LearnerFcstBaggedModel$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    LearnerFcstBaggedModel$new()

------------------------------------------------------------------------

### `LearnerFcstBaggedModel$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstBaggedModel$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# \donttest{
# Define the Learner and set parameter values
learner = lrn("fcst.bagged")
print(learner)
#> 
#> ── <LearnerFcstBaggedModel> (fcst.bagged): Bagged Model ────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and forecast
#> • Predict Types: [response]
#> • Feature Types: logical, integer, numeric, character, factor, ordered,
#> POSIXct, and Date
#> • Encapsulation: none (fallback: -)
#> • Properties: featureless and missings
#> • Other settings: use_weights = 'error', predict_raw = 'FALSE'

# Define a Task
task = tsk("airpassengers")

# Create train and test set
ids = partition(task)

# Train the learner on the training ids
learner$train(task, row_ids = ids$train)

# Print the model
print(learner$model)
#> $model
#> Series: y 
#> Model:  baggedModel 
#> Call:   forecast::baggedModel(y = y, bootstrapped_series = bootstrapped_series)
#> 
#> $row_ids
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#> [26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50
#> [51] 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75
#> [76] 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96
#> 
#> $max_index
#> [1] "1956-12-01"
#> 
#> $step
#> [1] "month"
#> 

# Importance method
if ("importance" %in% learner$properties) print(learner$importance())

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 1364.065 
# }
```
