# ARFIMA Forecast Learner

ARFIMA model. Calls
[`forecast::arfima()`](https://pkg.robjhyndman.com/forecast/reference/arfima.html)
from package [forecast](https://CRAN.R-project.org/package=forecast).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.arfima")
    lrn("fcst.arfima")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”, “quantiles”

- Feature Types: “logical”, “integer”, “numeric”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [forecast](https://CRAN.R-project.org/package=forecast)

## Parameters

|                    |           |             |                                              |                       |
|--------------------|-----------|-------------|----------------------------------------------|-----------------------|
| Id                 | Type      | Default     | Levels                                       | Range                 |
| drange             | untyped   | c(0, 0.5)   |                                              | \-                    |
| estim              | character | mle         | mle, ls                                      | \-                    |
| lambda             | untyped   | NULL        |                                              | \-                    |
| biasadj            | logical   | FALSE       | TRUE, FALSE                                  | \-                    |
| d                  | integer   | NA          |                                              | \\\[0, \infty)\\      |
| D                  | integer   | NA          |                                              | \\\[0, \infty)\\      |
| max.p              | integer   | 5           |                                              | \\\[0, \infty)\\      |
| max.q              | integer   | 5           |                                              | \\\[0, \infty)\\      |
| max.order          | integer   | 5           |                                              | \\\[0, \infty)\\      |
| max.d              | integer   | 2           |                                              | \\\[0, \infty)\\      |
| max.D              | integer   | 1           |                                              | \\\[0, \infty)\\      |
| start.p            | integer   | 2           |                                              | \\\[0, \infty)\\      |
| start.q            | integer   | 2           |                                              | \\\[0, \infty)\\      |
| start.P            | integer   | 2           |                                              | \\\[0, \infty)\\      |
| start.Q            | integer   | 2           |                                              | \\\[0, \infty)\\      |
| seasonal           | logical   | FALSE       | TRUE, FALSE                                  | \-                    |
| ic                 | character | aicc        | aicc, aic, bic                               | \-                    |
| stepwise           | logical   | FALSE       | TRUE, FALSE                                  | \-                    |
| nmodels            | integer   | 94          |                                              | \\\[0, \infty)\\      |
| trace              | logical   | FALSE       | TRUE, FALSE                                  | \-                    |
| approximation      | untyped   | \-          |                                              | \-                    |
| method             | untyped   | NULL        |                                              | \-                    |
| truncate           | untyped   | NULL        |                                              | \-                    |
| test               | character | kpss        | kpss, adf, pp                                | \-                    |
| test.args          | untyped   | list()      |                                              | \-                    |
| seasonal.test      | character | seas        | seas, ocsb, hegy, ch                         | \-                    |
| seasonal.test.args | untyped   | list()      |                                              | \-                    |
| allowdrift         | logical   | TRUE        | TRUE, FALSE                                  | \-                    |
| allowmean          | logical   | TRUE        | TRUE, FALSE                                  | \-                    |
| parallel           | logical   | FALSE       | TRUE, FALSE                                  | \-                    |
| num.cores          | integer   | 2           |                                              | \\\[1, \infty)\\      |
| include.mean       | logical   | TRUE        | TRUE, FALSE                                  | \-                    |
| include.drift      | logical   | FALSE       | TRUE, FALSE                                  | \-                    |
| include.constant   | logical   | FALSE       | TRUE, FALSE                                  | \-                    |
| transform.pars     | logical   | TRUE        | TRUE, FALSE                                  | \-                    |
| fixed              | untyped   | NULL        |                                              | \-                    |
| init               | untyped   | NULL        |                                              | \-                    |
| SSinit             | character | Gardner1980 | Gardner1980, Rossignol2011                   | \-                    |
| n.cond             | integer   | \-          |                                              | \\\[1, \infty)\\      |
| optim.method       | character | BFGS        | Nelder-Mead, BFGS, CG, L-BFGS-B, SANN, Brent | \-                    |
| optim.control      | untyped   | list()      |                                              | \-                    |
| kappa              | numeric   | 1e+06       |                                              | \\(-\infty, \infty)\\ |

## References

Haslett, John, Raftery, E A (1989). “Space-time Modelling with
Long-memory Dependence: Assessing Ireland's Wind Power Resource.”
*Journal of the Royal Statistical Society: Series C (Applied
Statistics)*, **38**(1), 1–21.

Hyndman, J. R, Khandakar, Yeasmin (2008). “Automatic Time Series
Forecasting: The forecast Package for R.” *Journal of Statistical
Software*, **27**(3), 1–22.
[doi:10.18637/jss.v027.i03](https://doi.org/10.18637/jss.v027.i03) ,
<https://www.jstatsoft.org/index.php/jss/article/view/v027i03>.

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
[`mlr_learners_fcst.arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.arima.md),
[`mlr_learners_fcst.auto_adam`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_adam.md),
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
-\>
[`mlr3forecast::LearnerFcstForecast`](https://mlr3forecast.mlr-org.com/reference/LearnerFcstForecast.md)
-\> `LearnerFcstArfima`

## Methods

### Public methods

- [`LearnerFcstArfima$new()`](#method-LearnerFcstArfima-new)

- [`LearnerFcstArfima$clone()`](#method-LearnerFcstArfima-clone)

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

    LearnerFcstArfima$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstArfima$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.arfima")
print(learner)
#> 
#> ── <LearnerFcstArfima> (fcst.arfima): ARFIMA ───────────────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and forecast
#> • Predict Types: [response] and quantiles
#> • Feature Types: logical, integer, and numeric
#> • Encapsulation: none (fallback: -)
#> • Properties: exogenous, featureless, and missings
#> • Other settings: use_weights = 'error'

# Define a Task
task = tsk("airpassengers")

# Create train and test set
ids = partition(task)

# Train the learner on the training ids
learner$train(task, row_ids = ids$train)

# Print the model
print(learner$model)
#> 
#> Call:
#>   forecast::arfima(y = as.ts(task), xreg = xreg) 
#> 
#> *** Warning during (fracdf) fit: C fracdf() optimization failure
#>  
#> *** Warning during (fdcov) fit: unable to compute correlation matrix; maybe change 'h'
#> 
#> Coefficients:
#>          d     ar.ar1     ar.ar2     ma.ma1 
#>  0.3093729  0.1950795  0.4392743 -0.8524371 
#> sigma[eps] = 18.21006 
#> a list with components:
#>  [1] "log.likelihood"  "n"               "msg"             "d"              
#>  [5] "ar"              "ma"              "covariance.dpq"  "fnormMin"       
#>  [9] "sigma"           "stderror.dpq"    "correlation.dpq" "h"              
#> [13] "d.tol"           "M"               "hessian.dpq"     "length.w"       
#> [17] "residuals"       "fitted"          "call"            "x"              
#> [21] "series"         

# Importance method
if ("importance" %in% learner$properties) print(learner$importance)

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 33706.15 
```
