# Croston Forecast Learner

Croston model. Calls
[`forecast::croston_model()`](https://pkg.robjhyndman.com/forecast/reference/croston_model.html)
from package [forecast](https://CRAN.R-project.org/package=forecast).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.croston")
    lrn("fcst.croston")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”

- Feature Types: “logical”, “integer”, “numeric”, “character”, “factor”,
  “ordered”, “POSIXct”, “Date”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [forecast](https://CRAN.R-project.org/package=forecast)

## Parameters

|        |           |         |                   |              |
|--------|-----------|---------|-------------------|--------------|
| Id     | Type      | Default | Levels            | Range        |
| alpha  | numeric   | 0.1     |                   | \\\[0, 1\]\\ |
| type   | character | croston | croston, sba, sbj | \-           |
| period | untyped   | NULL    |                   | \-           |

## References

Croston JD (1972). “Forecasting and stock control for intermittent
demands.” *Operational Research Quarterly*, **23**(3), 289–303.
[doi:10.2307/3007885](https://doi.org/10.2307/3007885) .

Shale EA, Boylan JE, Johnston FR (2006). “Forecasting for intermittent
demand: the estimation of an unbiased average.” *Journal of the
Operational Research Society*, **57**(5), 588–592.
[doi:10.1057/palgrave.jors.2602031](https://doi.org/10.1057/palgrave.jors.2602031)
.

Shenstone L, Hyndman RJ (2005). “Stochastic models underlying Croston's
method for intermittent demand forecasting.” *Journal of Forecasting*,
**24**(6), 389–402.
[doi:10.1002/for.963](https://doi.org/10.1002/for.963) .

Syntetos AA, Boylan JE (2001). “On the bias of intermittent demand
estimates.” *International Journal of Production Economics*,
**71**(1-3), 457–466.
[doi:10.1016/S0925-5273(00)00143-2](https://doi.org/10.1016/S0925-5273%2800%2900143-2)
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
[`mlr_learners_fcst.ar`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ar.md),
[`mlr_learners_fcst.arfima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.arfima.md),
[`mlr_learners_fcst.arima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.arima.md),
[`mlr_learners_fcst.auto_adam`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_adam.md),
[`mlr_learners_fcst.auto_arima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_arima.md),
[`mlr_learners_fcst.auto_ces`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_ces.md),
[`mlr_learners_fcst.auto_gum`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_gum.md),
[`mlr_learners_fcst.auto_msarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_msarima.md),
[`mlr_learners_fcst.auto_ssarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_ssarima.md),
[`mlr_learners_fcst.bagged`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.bagged.md),
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.dotm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.dotm.md),
[`mlr_learners_fcst.dstm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.dstm.md),
[`mlr_learners_fcst.elm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.elm.md),
[`mlr_learners_fcst.es`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.es.md),
[`mlr_learners_fcst.esn`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.esn.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.gum`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.gum.md),
[`mlr_learners_fcst.holt_winters`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.holt_winters.md),
[`mlr_learners_fcst.imapa`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.imapa.md),
[`mlr_learners_fcst.mean`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mean.md),
[`mlr_learners_fcst.mlp`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mlp.md),
[`mlr_learners_fcst.msarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.msarima.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.otm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.otm.md),
[`mlr_learners_fcst.prophet`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.prophet.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.rlgt`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.rlgt.md),
[`mlr_learners_fcst.sma`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.sma.md),
[`mlr_learners_fcst.snaive`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.snaive.md),
[`mlr_learners_fcst.sparma`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.sparma.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.ssarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ssarima.md),
[`mlr_learners_fcst.stheta`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.stheta.md),
[`mlr_learners_fcst.stlm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.stlm.md),
[`mlr_learners_fcst.stm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.stm.md),
[`mlr_learners_fcst.struct_ts`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.struct_ts.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.theta.md),
[`mlr_learners_fcst.tsb`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tsb.md),
[`mlr_learners_fcst.tscount`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tscount.md),
[`mlr_learners_fcst.tslm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tslm.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcst.md)
-\>
[`LearnerFcstForecast`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcstForecast.md)
-\> `LearnerFcstCroston`

## Methods

### Public methods

- [`LearnerFcstCroston$new()`](#method-LearnerFcstCroston-initialize)

- [`LearnerFcstCroston$clone()`](#method-LearnerFcstCroston-clone)

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
- [`LearnerFcst$predict_newdata_fast()`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcst.html#method-predict_newdata_fast)

------------------------------------------------------------------------

### `LearnerFcstCroston$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    LearnerFcstCroston$new()

------------------------------------------------------------------------

### `LearnerFcstCroston$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstCroston$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.croston")
print(learner)
#> 
#> ── <LearnerFcstCroston> (fcst.croston): Croston ────────────────────────────────
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
#> Call: croston_model(y = passengers) 
#> 
#> alpha: 0.1 
#> method: croston 
#> 
#> $index
#>  [1] "1949-01-01" "1949-02-01" "1949-03-01" "1949-04-01" "1949-05-01"
#>  [6] "1949-06-01" "1949-07-01" "1949-08-01" "1949-09-01" "1949-10-01"
#> [11] "1949-11-01" "1949-12-01" "1950-01-01" "1950-02-01" "1950-03-01"
#> [16] "1950-04-01" "1950-05-01" "1950-06-01" "1950-07-01" "1950-08-01"
#> [21] "1950-09-01" "1950-10-01" "1950-11-01" "1950-12-01" "1951-01-01"
#> [26] "1951-02-01" "1951-03-01" "1951-04-01" "1951-05-01" "1951-06-01"
#> [31] "1951-07-01" "1951-08-01" "1951-09-01" "1951-10-01" "1951-11-01"
#> [36] "1951-12-01" "1952-01-01" "1952-02-01" "1952-03-01" "1952-04-01"
#> [41] "1952-05-01" "1952-06-01" "1952-07-01" "1952-08-01" "1952-09-01"
#> [46] "1952-10-01" "1952-11-01" "1952-12-01" "1953-01-01" "1953-02-01"
#> [51] "1953-03-01" "1953-04-01" "1953-05-01" "1953-06-01" "1953-07-01"
#> [56] "1953-08-01" "1953-09-01" "1953-10-01" "1953-11-01" "1953-12-01"
#> [61] "1954-01-01" "1954-02-01" "1954-03-01" "1954-04-01" "1954-05-01"
#> [66] "1954-06-01" "1954-07-01" "1954-08-01" "1954-09-01" "1954-10-01"
#> [71] "1954-11-01" "1954-12-01" "1955-01-01" "1955-02-01" "1955-03-01"
#> [76] "1955-04-01" "1955-05-01" "1955-06-01" "1955-07-01" "1955-08-01"
#> [81] "1955-09-01" "1955-10-01" "1955-11-01" "1955-12-01" "1956-01-01"
#> [86] "1956-02-01" "1956-03-01" "1956-04-01" "1956-05-01" "1956-06-01"
#> [91] "1956-07-01" "1956-08-01" "1956-09-01" "1956-10-01" "1956-11-01"
#> [96] "1956-12-01"
#> 
#> $step
#> [1] "1 month"
#> 
#> $anchor
#> [1] 1
#> 

# Importance method
if ("importance" %in% learner$properties) print(learner$importance())

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 16044.81 
```
