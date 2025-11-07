# ETS Forecast Learner

Exponential Smoothing State Space (ETS) model. Calls
[`forecast::ets()`](https://pkg.robjhyndman.com/forecast/reference/ets.html)
from package [forecast](https://CRAN.R-project.org/package=forecast).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.ets")
    lrn("fcst.ets")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”, “quantiles”

- Feature Types: “logical”, “integer”, “numeric”, “character”, “factor”,
  “ordered”, “POSIXct”, “Date”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [forecast](https://CRAN.R-project.org/package=forecast)

## Parameters

|                            |           |                             |                                   |                       |
|----------------------------|-----------|-----------------------------|-----------------------------------|-----------------------|
| Id                         | Type      | Default                     | Levels                            | Range                 |
| model                      | untyped   | "ZZZ"                       |                                   | \-                    |
| damped                     | logical   | NULL                        | TRUE, FALSE                       | \-                    |
| alpha                      | numeric   | NULL                        |                                   | \\(-\infty, \infty)\\ |
| beta                       | numeric   | NULL                        |                                   | \\(-\infty, \infty)\\ |
| gamma                      | numeric   | NULL                        |                                   | \\(-\infty, \infty)\\ |
| phi                        | numeric   | NULL                        |                                   | \\(-\infty, \infty)\\ |
| additive.only              | logical   | FALSE                       | TRUE, FALSE                       | \-                    |
| lambda                     | untyped   | NULL                        |                                   | \-                    |
| biasadj                    | logical   | FALSE                       | TRUE, FALSE                       | \-                    |
| lower                      | untyped   | c(rep.int(1e-04, 3), 0.8)   |                                   | \-                    |
| upper                      | untyped   | c(rep.int(0.9999, 3), 0.98) |                                   | \-                    |
| opt.crit                   | character | lik                         | lik, amse, mse, sigma, mae        | \-                    |
| nmse                       | integer   | 3                           |                                   | \\\[0, 30\]\\         |
| bounds                     | character | both                        | both, usual, admissible           | \-                    |
| ic                         | character | aicc                        | aicc, aic, bic                    | \-                    |
| restrict                   | logical   | TRUE                        | TRUE, FALSE                       | \-                    |
| allow.multiplicative.trend | logical   | FALSE                       | TRUE, FALSE                       | \-                    |
| na.action                  | character | na.contiguous               | na.contiguous, na.interp, na.fail | \-                    |
| simulate                   | logical   | FALSE                       | TRUE, FALSE                       | \-                    |
| bootstrap                  | logical   | FALSE                       | TRUE, FALSE                       | \-                    |
| npaths                     | integer   | 5000                        |                                   | \\\[1, \infty)\\      |

## References

Hyndman, R.J., Koehler, A.B., Snyder, R.D., Grose, S. (2002). “A state
space framework for automatic forecasting using exponential smoothing
methods.” *International J. Forecasting*, **18**(3), 439–454.

Hyndman, R.J., Akram, Md., Archibald, B. (2008). “The admissible
parameter space for exponential smoothing models.” *Annals of
Statistical Mathematics*, **60**(2), 407–426.

Hyndman, R.J., Koehler, A.B., Ord, J.K., Snyder, R.D. (2008).
*Forecasting with exponential smoothing: the state space approach*.
Springer-Verlag. <http://www.exponentialsmoothing.net>.

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
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tbats.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`mlr3forecast::LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md)
-\>
[`mlr3forecast::LearnerFcstForecast`](https://mlr3forecast.mlr-org.com/reference/LearnerFcstForecast.md)
-\> `LearnerFcstEts`

## Methods

### Public methods

- [`LearnerFcstEts$new()`](#method-LearnerFcstEts-new)

- [`LearnerFcstEts$clone()`](#method-LearnerFcstEts-clone)

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

    LearnerFcstEts$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstEts$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.ets")
print(learner)
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

# Define a Task
task = tsk("airpassengers")

# Create train and test set
ids = partition(task)

# Train the learner on the training ids
learner$train(task, row_ids = ids$train)

# Print the model
print(learner$model)
#> ETS(M,Ad,M) 
#> 
#> Call:
#> forecast::ets(y = as.ts(task))
#> 
#>   Smoothing parameters:
#>     alpha = 0.6938 
#>     beta  = 0.0321 
#>     gamma = 1e-04 
#>     phi   = 0.9789 
#> 
#>   Initial states:
#>     l = 120.1012 
#>     b = 1.8118 
#>     s = 0.9047 0.7971 0.9166 1.0554 1.191 1.2065
#>            1.0963 0.9774 0.9928 1.0383 0.9118 0.912
#> 
#>   sigma:  0.038
#> 
#>      AIC     AICc      BIC 
#> 846.1827 855.0658 892.3409 

# Importance method
if ("importance" %in% learner$properties) print(learner$importance)

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 2983.694 
```
