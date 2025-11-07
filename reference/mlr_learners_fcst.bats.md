# BATS Forecast Learner

Exponential smoothing state space model with Box-Cox transformation,
ARMA errors, Trend and Seasonal components (BATS) model. Calls
[`forecast::bats()`](https://pkg.robjhyndman.com/forecast/reference/bats.html)
from package [forecast](https://CRAN.R-project.org/package=forecast).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.bats")
    lrn("fcst.bats")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”, “quantiles”

- Feature Types: “logical”, “integer”, “numeric”, “character”, “factor”,
  “ordered”, “POSIXct”, “Date”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [forecast](https://CRAN.R-project.org/package=forecast)

## Parameters

|                  |         |         |             |                       |
|------------------|---------|---------|-------------|-----------------------|
| Id               | Type    | Default | Levels      | Range                 |
| use.box.cox      | logical | NULL    | TRUE, FALSE | \-                    |
| use.trend        | logical | NULL    | TRUE, FALSE | \-                    |
| use.damped.trend | logical | NULL    | TRUE, FALSE | \-                    |
| seasonal.periods | untyped | NULL    |             | \-                    |
| use.arma.errors  | logical | NULL    | TRUE, FALSE | \-                    |
| use.parallel     | untyped | \-      |             | \-                    |
| num.cores        | integer | 2       |             | \\\[1, \infty)\\      |
| bc.lower         | integer | 0       |             | \\(-\infty, \infty)\\ |
| bc.upper         | integer | 1       |             | \\(-\infty, \infty)\\ |
| biasadj          | logical | FALSE   | TRUE, FALSE | \-                    |

## References

De Livera, A.M., Hyndman, R.J., Snyder &, D. R (2011). “Forecasting time
series with complex seasonal patterns using exponential smoothing.”
*Journal of the American Statistical Association*, **106**(496),
1513–1527.

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
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tbats.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`mlr3forecast::LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md)
-\>
[`mlr3forecast::LearnerFcstForecast`](https://mlr3forecast.mlr-org.com/reference/LearnerFcstForecast.md)
-\> `LearnerFcstBats`

## Methods

### Public methods

- [`LearnerFcstBats$new()`](#method-LearnerFcstBats-new)

- [`LearnerFcstBats$clone()`](#method-LearnerFcstBats-clone)

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

    LearnerFcstBats$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstBats$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.bats")
print(learner)
#> 
#> ── <LearnerFcstBats> (fcst.bats): BATS ─────────────────────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and forecast
#> • Predict Types: [response] and quantiles
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
#> TBATS(0, {0,0}, 1, {<12,5>})
#> 
#> Call: forecast::tbats(y = as.ts(task))
#> 
#> Parameters
#>   Lambda: 0
#>   Alpha: 0.6705538
#>   Beta: 0.04675065
#>   Damping Parameter: 1
#>   Gamma-1 Values: 0.004508484
#>   Gamma-2 Values: 0.01178641
#> 
#> Seed States:
#>               [,1]
#>  [1,]  4.808973955
#>  [2,] -0.006979784
#>  [3,] -0.132575268
#>  [4,]  0.049822202
#>  [5,] -0.009852127
#>  [6,]  0.007714254
#>  [7,]  0.001576272
#>  [8,]  0.035970508
#>  [9,]  0.062976543
#> [10,] -0.025967892
#> [11,] -0.036114544
#> [12,] -0.020072721
#> attr(,"lambda")
#> [1] 2.747722e-08
#> 
#> Sigma: 0.03474871
#> AIC: 846.5215

# Importance method
if ("importance" %in% learner$properties) print(learner$importance)

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 1761.171 
```
