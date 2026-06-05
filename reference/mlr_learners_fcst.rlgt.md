# Local and Global Trend Forecast Learner

Bayesian exponential smoothing with a nonlinear global trend (LGT/SGT),
Student-t errors, and optional heteroscedasticity, fitted via MCMC. The
seasonal period is taken from the frequency of the series. Calls
[`Rlgt::rlgt()`](https://rdrr.io/pkg/Rlgt/man/rlgt.html) from package
[Rlgt](https://CRAN.R-project.org/package=Rlgt).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.rlgt")
    lrn("fcst.rlgt")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”, “quantiles”

- Feature Types: “logical”, “integer”, “numeric”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [Rlgt](https://CRAN.R-project.org/package=Rlgt)

## Parameters

|  |  |  |  |  |
|----|----|----|----|----|
| Id | Type | Default | Levels | Range |
| seasonality | integer | 1 |  | \\\[1, \infty)\\ |
| seasonality2 | integer | 1 |  | \\\[1, \infty)\\ |
| seasonality.type | character | multiplicative | multiplicative, generalized | \- |
| error.size.method | character | std | std, innov | \- |
| level.method | character | HW | HW, seasAvg, HW_sAvg | \- |
| method | character | Gibbs | Gibbs, Stan | \- |
| homoscedastic | logical | FALSE | TRUE, FALSE | \- |
| control | untyped | NULL |  | \- |
| verbose | logical | FALSE | TRUE, FALSE | \- |
| NUM_OF_TRIALS | integer | 2000 |  | \\\[1, \infty)\\ |

## References

Smyl S, Bergmeir C, Wibowo E, Ng TW, Long X, Dokumentov A, Schmidt D
(2025). *Rlgt: Bayesian Exponential Smoothing Models with Trend
Modifications*. R package version 0.2-3,
<https://github.com/cbergmeir/Rlgt>.

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
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md),
[`mlr_learners_fcst.adam`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.adam.md),
[`mlr_learners_fcst.arfima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.arfima.md),
[`mlr_learners_fcst.arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.arima.md),
[`mlr_learners_fcst.auto_adam`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_adam.md),
[`mlr_learners_fcst.auto_arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_arima.md),
[`mlr_learners_fcst.auto_ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_ces.md),
[`mlr_learners_fcst.auto_gum`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_gum.md),
[`mlr_learners_fcst.auto_msarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_msarima.md),
[`mlr_learners_fcst.auto_ssarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_ssarima.md),
[`mlr_learners_fcst.bagged`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.bagged.md),
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.croston`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.croston.md),
[`mlr_learners_fcst.elm`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.elm.md),
[`mlr_learners_fcst.es`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.es.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.gum`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.gum.md),
[`mlr_learners_fcst.holt_winters`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.holt_winters.md),
[`mlr_learners_fcst.mean`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.mean.md),
[`mlr_learners_fcst.mlp`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.mlp.md),
[`mlr_learners_fcst.msarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.msarima.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.prophet`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.prophet.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.sma`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.sma.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.ssarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ssarima.md),
[`mlr_learners_fcst.stlm`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.stlm.md),
[`mlr_learners_fcst.struct_ts`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.struct_ts.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.theta.md),
[`mlr_learners_fcst.tscount`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tscount.md),
[`mlr_learners_fcst.tslm`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tslm.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md)
-\>
[`LearnerFcstForecast`](https://mlr3forecast.mlr-org.com/reference/LearnerFcstForecast.md)
-\> `LearnerFcstRlgt`

## Methods

### Public methods

- [`LearnerFcstRlgt$new()`](#method-LearnerFcstRlgt-initialize)

- [`LearnerFcstRlgt$clone()`](#method-LearnerFcstRlgt-clone)

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

### `LearnerFcstRlgt$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    LearnerFcstRlgt$new()

------------------------------------------------------------------------

### `LearnerFcstRlgt$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstRlgt$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.rlgt")
print(learner)
#> 
#> ── <LearnerFcstRlgt> (fcst.rlgt): Local and Global Trend ───────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and Rlgt
#> • Predict Types: [response] and quantiles
#> • Feature Types: logical, integer, and numeric
#> • Encapsulation: none (fallback: -)
#> • Properties: exogenous and featureless
#> • Other settings: use_weights = 'error', predict_raw = 'FALSE'

# Define a Task
task = tsk("airpassengers")

# Create train and test set
ids = partition(task)

# Train the learner on the training ids
learner$train(task, row_ids = ids$train)

# Print the model
print(learner$model)
#> $n.samples
#> [1] 5000
#> 
#> $sigma2
#> [1] 0.5273319
#> 
#> $xi2
#> [1] 1.880876
#> 
#> $phi
#> [1] 0.5862069
#> 
#> $chi2
#> [1] 11.77917
#> 
#> $chi2.lambda2
#> [1] 0
#> 
#> $w
#> [1] 0
#> 
#> $alpha
#> [1] 0.7312943
#> 
#> $beta
#> [1] 0.7
#> 
#> $zeta
#> [1] 0.4483512
#> 
#> $rho
#> [1] 0.06896552
#> 
#> $tau
#> [1] 0.3793103
#> 
#> $nu
#> [1] 8.84
#> 
#> $l1
#> [1] 0
#> 
#> $b1
#> [1] 0
#> 
#> $lt
#> [1] 332.1843
#> 
#> $bt
#> [1] 0
#> 
#> $et
#> [1] -2.87257
#> 
#> $log.s
#> [1] 0.01170858
#> 
#> $y.on.l
#> [1] 0.0220278
#> 
#> $L
#> [1] 0
#> 
#> $log.s1
#> [1] -0.001672166
#> 
#> $w.s
#> [1] 0
#> 
#> $l2.log.s
#> [1] 0.8830086
#> 
#> $t2.log.s
#> [1] 0.01421203
#> 
#> $s.ix
#> [1] 7
#> 
#> $m
#> [1] 12
#> 
#> $y
#> [1] 200
#> 
#> $mu.hat
#> [1] 205.9102
#> 
#> $method
#> [1] "Gibbs"
#> 
#> $x
#> [1] 200
#> 

# Importance method
if ("importance" %in% learner$properties) print(learner$importance())

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 748.5569 
```
