# Echo state network forecast learner

Fits a univariate echo state network with a randomly initialized
recurrent reservoir and a ridge regression readout. Quantile predictions
are empirical quantiles of the future paths simulated by
[`echos::forecast_esn()`](https://ahaeusser.github.io/echos/reference/forecast_esn.html).
Calls
[`echos::train_esn()`](https://ahaeusser.github.io/echos/reference/train_esn.html)
and
[`echos::forecast_esn()`](https://ahaeusser.github.io/echos/reference/forecast_esn.html)
from package [echos](https://CRAN.R-project.org/package=echos).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.esn")
    lrn("fcst.esn")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”, “quantiles”

- Feature Types: “logical”, “integer”, “numeric”, “character”, “factor”,
  “ordered”, “POSIXct”, “Date”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [echos](https://CRAN.R-project.org/package=echos)

## Parameters

|  |  |  |  |  |
|----|----|----|----|----|
| Id | Type | Default | Levels | Range |
| lags | untyped | 1L |  | \- |
| inf_crit | character | bic | aic, aicc, bic, hqc | \- |
| n_diff | integer | NULL |  | \\\[0, \infty)\\ |
| n_states | integer | NULL |  | \\\[1, \infty)\\ |
| n_models | integer | NULL |  | \\\[1, \infty)\\ |
| n_initial | integer | NULL |  | \\\[0, \infty)\\ |
| n_seed | integer | 42 |  | \\\[0, 2147483647\]\\ |
| alpha | numeric | 1 |  | \\\[0, 1\]\\ |
| rho | numeric | 1 |  | \\\[0, \infty)\\ |
| tau | numeric | 0.4 |  | \\\[0, 1\]\\ |
| density | numeric | 0.5 |  | \\\[0, 1\]\\ |
| lambda | untyped | c(1e-04, 2) |  | \- |
| scale_win | numeric | 0.5 |  | \\\[0, \infty)\\ |
| scale_wres | numeric | 0.5 |  | \\\[0, \infty)\\ |
| scale_inputs | untyped | c(-0.5, 0.5) |  | \- |
| n_sim | integer | 100 |  | \\\[1, \infty)\\ |

## References

Häußer A (2026). “Echo State Networks for Time Series Forecasting:
Hyperparameter Sweep and Benchmarking.” 2602.03912,
<https://arxiv.org/abs/2602.03912>.

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
[`mlr_learners_fcst.croston`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.croston.md),
[`mlr_learners_fcst.elm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.elm.md),
[`mlr_learners_fcst.es`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.es.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.gum`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.gum.md),
[`mlr_learners_fcst.holt_winters`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.holt_winters.md),
[`mlr_learners_fcst.imapa`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.imapa.md),
[`mlr_learners_fcst.mean`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mean.md),
[`mlr_learners_fcst.mlp`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mlp.md),
[`mlr_learners_fcst.msarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.msarima.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.prophet`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.prophet.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.rlgt`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.rlgt.md),
[`mlr_learners_fcst.sma`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.sma.md),
[`mlr_learners_fcst.snaive`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.snaive.md),
[`mlr_learners_fcst.sparma`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.sparma.md),
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
-\> `LearnerFcstEsn`

## Methods

### Public methods

- [`LearnerFcstEsn$new()`](#method-LearnerFcstEsn-initialize)

- [`LearnerFcstEsn$clone()`](#method-LearnerFcstEsn-clone)

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

### `LearnerFcstEsn$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    LearnerFcstEsn$new()

------------------------------------------------------------------------

### `LearnerFcstEsn$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstEsn$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.esn")
print(learner)
#> 
#> ── <LearnerFcstEsn> (fcst.esn): Echo State Network ─────────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and echos
#> • Predict Types: [response] and quantiles
#> • Feature Types: logical, integer, numeric, character, factor, ordered,
#> POSIXct, and Date
#> • Encapsulation: none (fallback: -)
#> • Properties: featureless
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
#> ESN({38, 1, 1}, {76, 15.86})
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
#> 1119.704 
```
