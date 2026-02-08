# Auto ADAM Forecast Learner

Auto Augmented Dynamic Adaptive Model (ADAM) model. Calls
[`smooth::auto.adam()`](https://rdrr.io/pkg/smooth/man/adam.html) from
package [smooth](https://CRAN.R-project.org/package=smooth).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.auto_adam")
    lrn("fcst.auto_adam")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”

- Feature Types: “logical”, “integer”, “numeric”, “character”, “factor”,
  “ordered”, “POSIXct”, “Date”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [smooth](https://CRAN.R-project.org/package=smooth)

## Parameters

|              |           |              |                                                                    |
|--------------|-----------|--------------|--------------------------------------------------------------------|
| Id           | Type      | Default      | Levels                                                             |
| model        | untyped   | "ZXZ"        |                                                                    |
| lags         | untyped   | \-           |                                                                    |
| orders       | untyped   | \-           |                                                                    |
| regressors   | character | use          | use, select, adapt                                                 |
| occurrence   | character | none         | none, auto, fixed, general, odds-ratio, inverse-odds-ratio, direct |
| distribution | character | dnorm        | dnorm, dlaplace, ds, dgnorm, dlnorm, dinvgauss, dgamma             |
| outliers     | character | ignore       | ignore, use, select                                                |
| holdout      | logical   | FALSE        | TRUE, FALSE                                                        |
| persistence  | untyped   | NULL         |                                                                    |
| phi          | untyped   | NULL         |                                                                    |
| initial      | character | optimal      | optimal, backcasting, complete                                     |
| arma         | untyped   | NULL         |                                                                    |
| ic           | character | AICc         | AICc, AIC, BIC, BICc                                               |
| bounds       | character | usual        | usual, admissible, none                                            |
| silent       | logical   | TRUE         | TRUE, FALSE                                                        |
| parallel     | logical   | FALSE        | TRUE, FALSE                                                        |
| ets          | character | conventional | conventional, adam                                                 |

## References

Svetunkov I (2023). “Smooth forecasting with the smooth package in R.”
2301.01790, <https://arxiv.org/abs/2301.01790>.

Svetunkov, Ivan (2023). *Forecasting and Analytics with the Augmented
Dynamic Adaptive Model (ADAM)*, 1st edition. Chapman and Hall/CRC.
[doi:10.1201/9781003452652](https://doi.org/10.1201/9781003452652) ,
<https://openforecast.org/adam/>.

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
[`mlr_learners_fcst.auto_arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_arima.md),
[`mlr_learners_fcst.auto_ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_ces.md),
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.croston`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.croston.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.theta.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`mlr3forecast::LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md)
-\> `LearnerFcstAutoAdam`

## Methods

### Public methods

- [`LearnerFcstAutoAdam$new()`](#method-LearnerFcstAutoAdam-new)

- [`LearnerFcstAutoAdam$clone()`](#method-LearnerFcstAutoAdam-clone)

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

    LearnerFcstAutoAdam$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstAutoAdam$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.auto_adam")
print(learner)
#> 
#> ── <LearnerFcstAutoAdam> (fcst.auto_adam): Auto ADAM ───────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and smooth
#> • Predict Types: [response]
#> • Feature Types: logical, integer, numeric, character, factor, ordered,
#> POSIXct, and Date
#> • Encapsulation: none (fallback: -)
#> • Properties: featureless and missings
#> • Other settings: use_weights = 'error'

# Define a Task
task = tsk("airpassengers")

# Create train and test set
ids = partition(task)

# Train the learner on the training ids
learner$train(task, row_ids = ids$train)

# Print the model
print(learner$model)
#> Time elapsed: 3.76 seconds
#> Model estimated using auto.adam() function: ETS(MAM)
#> With backcasting initialisation
#> Distribution assumed in the model: Normal
#> Loss function type: likelihood; Loss function value: 327.5537
#> Persistence vector g:
#>  alpha   beta  gamma 
#> 0.5640 0.0000 0.1468 
#> 
#> Sample size: 96
#> Number of estimated parameters: 4
#> Number of degrees of freedom: 92
#> Information criteria:
#>      AIC     AICc      BIC     BICc 
#> 663.1073 663.5469 673.3647 674.3679 

# Importance method
if ("importance" %in% learner$properties) print(learner$importance)

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 1233.255 
```
