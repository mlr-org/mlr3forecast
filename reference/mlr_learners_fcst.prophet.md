# Prophet Forecast Learner

Prophet model. Calls
[`prophet::prophet()`](https://rdrr.io/pkg/prophet/man/prophet.html)
from package [prophet](https://CRAN.R-project.org/package=prophet).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.prophet")
    lrn("fcst.prophet")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”

- Feature Types: “logical”, “integer”, “numeric”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [prophet](https://CRAN.R-project.org/package=prophet)

## Parameters

|                         |           |          |                          |                  |
|-------------------------|-----------|----------|--------------------------|------------------|
| Id                      | Type      | Default  | Levels                   | Range            |
| growth                  | character | linear   | linear, logistic, flat   | \-               |
| n.changepoints          | integer   | 25       |                          | \\\[0, \infty)\\ |
| changepoint.range       | numeric   | 0.8      |                          | \\\[0, 1\]\\     |
| yearly.seasonality      | untyped   | "auto"   |                          | \-               |
| weekly.seasonality      | untyped   | "auto"   |                          | \-               |
| daily.seasonality       | untyped   | "auto"   |                          | \-               |
| seasonality.mode        | character | additive | additive, multiplicative | \-               |
| seasonality.prior.scale | numeric   | 10       |                          | \\\[0, \infty)\\ |
| holidays.prior.scale    | numeric   | 10       |                          | \\\[0, \infty)\\ |
| changepoint.prior.scale | numeric   | 0.05     |                          | \\\[0, \infty)\\ |
| mcmc.samples            | integer   | 0        |                          | \\\[0, \infty)\\ |
| interval.width          | numeric   | 0.8      |                          | \\\[0, 1\]\\     |
| uncertainty.samples     | integer   | 1000     |                          | \\\[0, \infty)\\ |

## References

Taylor, J. S, Letham, Benjamin (2018). “Forecasting at Scale.” *The
American Statistician*, **72**(1), 37–45.
[doi:10.1080/00031305.2017.1380080](https://doi.org/10.1080/00031305.2017.1380080)
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
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md),
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
[`mlr_learners_fcst.mean`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.mean.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.theta.md),
[`mlr_learners_fcst.tscount`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tscount.md),
[`mlr_learners_fcst.tslm`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tslm.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`mlr3forecast::LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md)
-\> `LearnerFcstProphet`

## Methods

### Public methods

- [`LearnerFcstProphet$new()`](#method-LearnerFcstProphet-new)

- [`LearnerFcstProphet$clone()`](#method-LearnerFcstProphet-clone)

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

    LearnerFcstProphet$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstProphet$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.prophet")
print(learner)
#> 
#> ── <LearnerFcstProphet> (fcst.prophet): Prophet ────────────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and prophet
#> • Predict Types: [response]
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
#> Disabling weekly seasonality. Run prophet with weekly.seasonality=TRUE to override this.
#> Disabling daily seasonality. Run prophet with daily.seasonality=TRUE to override this.

# Print the model
print(learner$model)
#> $growth
#> [1] "linear"
#> 
#> $changepoints
#>  [1] "1949-04-01 GMT" "1949-07-01 GMT" "1949-10-01 GMT" "1950-01-01 GMT"
#>  [5] "1950-04-01 GMT" "1950-07-01 GMT" "1950-10-01 GMT" "1951-01-01 GMT"
#>  [9] "1951-04-01 GMT" "1951-07-01 GMT" "1951-10-01 GMT" "1952-01-01 GMT"
#> [13] "1952-04-01 GMT" "1952-07-01 GMT" "1952-10-01 GMT" "1953-01-01 GMT"
#> [17] "1953-04-01 GMT" "1953-07-01 GMT" "1953-10-01 GMT" "1954-01-01 GMT"
#> [21] "1954-04-01 GMT" "1954-07-01 GMT" "1954-10-01 GMT" "1955-01-01 GMT"
#> [25] "1955-04-01 GMT"
#> 
#> $n.changepoints
#> [1] 25
#> 
#> $changepoint.range
#> [1] 0.8
#> 
#> $yearly.seasonality
#> [1] "auto"
#> 
#> $weekly.seasonality
#> [1] "auto"
#> 
#> $daily.seasonality
#> [1] "auto"
#> 
#> $holidays
#> NULL
#> 
#> $seasonality.mode
#> [1] "additive"
#> 
#> $seasonality.prior.scale
#> [1] 10
#> 
#> $changepoint.prior.scale
#> [1] 0.05
#> 
#> $holidays.prior.scale
#> [1] 10
#> 
#> $mcmc.samples
#> [1] 0
#> 
#> $interval.width
#> [1] 0.8
#> 
#> $uncertainty.samples
#> [1] 1000
#> 
#> $backend
#> [1] "rstan"
#> 
#> $specified.changepoints
#> [1] FALSE
#> 
#> $start
#> [1] "1949-01-01 GMT"
#> 
#> $y.scale
#> [1] 413
#> 
#> $logistic.floor
#> [1] FALSE
#> 
#> $t.scale
#> [1] 249782400
#> 
#> $changepoints.t
#>  [1] 0.03113110 0.06260809 0.09443099 0.12625389 0.15738499 0.18886199
#>  [7] 0.22068488 0.25250778 0.28363888 0.31511588 0.34693878 0.37876167
#> [13] 0.41023867 0.44171567 0.47353857 0.50536147 0.53649256 0.56796956
#> [19] 0.59979246 0.63161536 0.66274645 0.69422345 0.72604635 0.75786925
#> [25] 0.78900035
#> 
#> $seasonalities
#> $seasonalities$yearly
#> $seasonalities$yearly$period
#> [1] 365.25
#> 
#> $seasonalities$yearly$fourier.order
#> [1] 10
#> 
#> $seasonalities$yearly$prior.scale
#> [1] 10
#> 
#> $seasonalities$yearly$mode
#> [1] "additive"
#> 
#> $seasonalities$yearly$condition.name
#> NULL
#> 
#> 
#> 
#> $extra_regressors
#> list()
#> 
#> $country_holidays
#> NULL
#> 
#> $stan.fit
#> $stan.fit$par
#> $stan.fit$par$k
#> [1] 0.4689463
#> 
#> $stan.fit$par$m
#> [1] 0.2626889
#> 
#> $stan.fit$par$delta
#>  [1] -1.629715e-09 -2.975927e-09  8.297789e-09  7.386490e-07  2.439990e-04
#>  [6]  1.860079e-04  3.569261e-04  2.485746e-05  1.761411e-04  2.936178e-06
#> [11]  7.713242e-08  1.372669e-09  1.270641e-09 -8.890979e-10 -5.260771e-09
#> [16]  4.257928e-09 -2.150120e-09 -1.346344e-09  2.918624e-07  2.275125e-04
#> [21]  1.586052e-01  9.010031e-04  1.609569e-01  3.197192e-04  1.052971e-04
#> 
#> $stan.fit$par$sigma_obs
#> [1] 0.03086558
#> 
#> $stan.fit$par$beta
#>  [1]  0.0114843482 -0.0772540278  0.0914684719 -0.0139456812 -0.0008688399
#>  [6] -0.0305315941 -0.0244766354 -0.0226173303  0.0737712486 -0.0091661606
#> [11] -0.0598928092 -0.0075000965  0.0780312298  0.0289800360 -0.0066524083
#> [16]  0.0240784624  0.0124974429  0.0229542877  0.0542470663  0.0520124837
#> 
#> $stan.fit$par$trend
#>  [1] 0.2626889 0.2677174 0.2722592 0.2772877 0.2821540 0.2871825 0.2920487
#>  [8] 0.2970772 0.3021057 0.3069720 0.3120004 0.3168667 0.3218952 0.3269237
#> [15] 0.3314655 0.3364940 0.3413628 0.3463939 0.3512627 0.3562958 0.3613289
#> [22] 0.3661997 0.3712366 0.3761111 0.3811480 0.3861852 0.3907349 0.3957721
#> [29] 0.4006486 0.4056877 0.4105642 0.4156033 0.4206425 0.4255190 0.4305581
#> [36] 0.4354347 0.4404738 0.4455129 0.4502269 0.4552660 0.4601426 0.4651817
#> [43] 0.4700583 0.4750974 0.4801365 0.4850131 0.4900522 0.4949287 0.4999679
#> [50] 0.5050070 0.5095584 0.5145975 0.5194741 0.5245132 0.5293898 0.5344289
#> [57] 0.5394680 0.5443446 0.5493837 0.5542602 0.5592994 0.5643409 0.5688946
#> [64] 0.5739361 0.5804609 0.5872032 0.5937280 0.6004799 0.6072318 0.6137659
#> [71] 0.6222438 0.6304482 0.6389261 0.6474073 0.6550679 0.6635491 0.6717579
#> [78] 0.6802404 0.6884492 0.6969316 0.7054140 0.7136228 0.7221052 0.7303140
#> [85] 0.7387964 0.7472788 0.7552140 0.7636964 0.7719052 0.7803876 0.7885964
#> [92] 0.7970788 0.8055612 0.8137700 0.8222525 0.8304613
#> 
#> 
#> $stan.fit$value
#> [1] 279.4412
#> 
#> $stan.fit$return_code
#> [1] 0
#> 
#> $stan.fit$theta_tilde
#>              k         m      delta[1]      delta[2]     delta[3]    delta[4]
#> [1,] 0.4689463 0.2626889 -1.629715e-09 -2.975927e-09 8.297789e-09 7.38649e-07
#>         delta[5]     delta[6]     delta[7]     delta[8]     delta[9]
#> [1,] 0.000243999 0.0001860079 0.0003569261 2.485746e-05 0.0001761411
#>         delta[10]    delta[11]    delta[12]    delta[13]     delta[14]
#> [1,] 2.936178e-06 7.713242e-08 1.372669e-09 1.270641e-09 -8.890979e-10
#>          delta[15]    delta[16]    delta[17]     delta[18]    delta[19]
#> [1,] -5.260771e-09 4.257928e-09 -2.15012e-09 -1.346344e-09 2.918624e-07
#>         delta[20] delta[21]    delta[22] delta[23]    delta[24]    delta[25]
#> [1,] 0.0002275125 0.1586052 0.0009010031 0.1609569 0.0003197192 0.0001052971
#>       sigma_obs    beta[1]     beta[2]    beta[3]     beta[4]       beta[5]
#> [1,] 0.03086558 0.01148435 -0.07725403 0.09146847 -0.01394568 -0.0008688399
#>          beta[6]     beta[7]     beta[8]    beta[9]     beta[10]    beta[11]
#> [1,] -0.03053159 -0.02447664 -0.02261733 0.07377125 -0.009166161 -0.05989281
#>          beta[12]   beta[13]   beta[14]     beta[15]   beta[16]   beta[17]
#> [1,] -0.007500096 0.07803123 0.02898004 -0.006652408 0.02407846 0.01249744
#>        beta[18]   beta[19]   beta[20]  trend[1]  trend[2]  trend[3]  trend[4]
#> [1,] 0.02295429 0.05424707 0.05201248 0.2626889 0.2677174 0.2722592 0.2772877
#>      trend[5]  trend[6]  trend[7]  trend[8]  trend[9] trend[10] trend[11]
#> [1,] 0.282154 0.2871825 0.2920487 0.2970772 0.3021057  0.306972 0.3120004
#>      trend[12] trend[13] trend[14] trend[15] trend[16] trend[17] trend[18]
#> [1,] 0.3168667 0.3218952 0.3269237 0.3314655  0.336494 0.3413628 0.3463939
#>      trend[19] trend[20] trend[21] trend[22] trend[23] trend[24] trend[25]
#> [1,] 0.3512627 0.3562958 0.3613289 0.3661997 0.3712366 0.3761111  0.381148
#>      trend[26] trend[27] trend[28] trend[29] trend[30] trend[31] trend[32]
#> [1,] 0.3861852 0.3907349 0.3957721 0.4006486 0.4056877 0.4105642 0.4156033
#>      trend[33] trend[34] trend[35] trend[36] trend[37] trend[38] trend[39]
#> [1,] 0.4206425  0.425519 0.4305581 0.4354347 0.4404738 0.4455129 0.4502269
#>      trend[40] trend[41] trend[42] trend[43] trend[44] trend[45] trend[46]
#> [1,]  0.455266 0.4601426 0.4651817 0.4700583 0.4750974 0.4801365 0.4850131
#>      trend[47] trend[48] trend[49] trend[50] trend[51] trend[52] trend[53]
#> [1,] 0.4900522 0.4949287 0.4999679  0.505007 0.5095584 0.5145975 0.5194741
#>      trend[54] trend[55] trend[56] trend[57] trend[58] trend[59] trend[60]
#> [1,] 0.5245132 0.5293898 0.5344289  0.539468 0.5443446 0.5493837 0.5542602
#>      trend[61] trend[62] trend[63] trend[64] trend[65] trend[66] trend[67]
#> [1,] 0.5592994 0.5643409 0.5688946 0.5739361 0.5804609 0.5872032  0.593728
#>      trend[68] trend[69] trend[70] trend[71] trend[72] trend[73] trend[74]
#> [1,] 0.6004799 0.6072318 0.6137659 0.6222438 0.6304482 0.6389261 0.6474073
#>      trend[75] trend[76] trend[77] trend[78] trend[79] trend[80] trend[81]
#> [1,] 0.6550679 0.6635491 0.6717579 0.6802404 0.6884492 0.6969316  0.705414
#>      trend[82] trend[83] trend[84] trend[85] trend[86] trend[87] trend[88]
#> [1,] 0.7136228 0.7221052  0.730314 0.7387964 0.7472788  0.755214 0.7636964
#>      trend[89] trend[90] trend[91] trend[92] trend[93] trend[94] trend[95]
#> [1,] 0.7719052 0.7803876 0.7885964 0.7970788 0.8055612   0.81377 0.8222525
#>      trend[96]
#> [1,] 0.8304613
#> 
#> 
#> $params
#> $params$k
#> [1] 0.4689463
#> 
#> $params$m
#> [1] 0.2626889
#> 
#> $params$delta
#>               [,1]          [,2]         [,3]        [,4]        [,5]
#> [1,] -1.629715e-09 -2.975927e-09 8.297789e-09 7.38649e-07 0.000243999
#>              [,6]         [,7]         [,8]         [,9]        [,10]
#> [1,] 0.0001860079 0.0003569261 2.485746e-05 0.0001761411 2.936178e-06
#>             [,11]        [,12]        [,13]         [,14]         [,15]
#> [1,] 7.713242e-08 1.372669e-09 1.270641e-09 -8.890979e-10 -5.260771e-09
#>             [,16]        [,17]         [,18]        [,19]        [,20]
#> [1,] 4.257928e-09 -2.15012e-09 -1.346344e-09 2.918624e-07 0.0002275125
#>          [,21]        [,22]     [,23]        [,24]        [,25]
#> [1,] 0.1586052 0.0009010031 0.1609569 0.0003197192 0.0001052971
#> 
#> $params$sigma_obs
#> [1] 0.03086558
#> 
#> $params$beta
#>            [,1]        [,2]       [,3]        [,4]          [,5]        [,6]
#> [1,] 0.01148435 -0.07725403 0.09146847 -0.01394568 -0.0008688399 -0.03053159
#>             [,7]        [,8]       [,9]        [,10]       [,11]        [,12]
#> [1,] -0.02447664 -0.02261733 0.07377125 -0.009166161 -0.05989281 -0.007500096
#>           [,13]      [,14]        [,15]      [,16]      [,17]      [,18]
#> [1,] 0.07803123 0.02898004 -0.006652408 0.02407846 0.01249744 0.02295429
#>           [,19]      [,20]
#> [1,] 0.05424707 0.05201248
#> 
#> $params$trend
#>  [1] 0.2626889 0.2677174 0.2722592 0.2772877 0.2821540 0.2871825 0.2920487
#>  [8] 0.2970772 0.3021057 0.3069720 0.3120004 0.3168667 0.3218952 0.3269237
#> [15] 0.3314655 0.3364940 0.3413628 0.3463939 0.3512627 0.3562958 0.3613289
#> [22] 0.3661997 0.3712366 0.3761111 0.3811480 0.3861852 0.3907349 0.3957721
#> [29] 0.4006486 0.4056877 0.4105642 0.4156033 0.4206425 0.4255190 0.4305581
#> [36] 0.4354347 0.4404738 0.4455129 0.4502269 0.4552660 0.4601426 0.4651817
#> [43] 0.4700583 0.4750974 0.4801365 0.4850131 0.4900522 0.4949287 0.4999679
#> [50] 0.5050070 0.5095584 0.5145975 0.5194741 0.5245132 0.5293898 0.5344289
#> [57] 0.5394680 0.5443446 0.5493837 0.5542602 0.5592994 0.5643409 0.5688946
#> [64] 0.5739361 0.5804609 0.5872032 0.5937280 0.6004799 0.6072318 0.6137659
#> [71] 0.6222438 0.6304482 0.6389261 0.6474073 0.6550679 0.6635491 0.6717579
#> [78] 0.6802404 0.6884492 0.6969316 0.7054140 0.7136228 0.7221052 0.7303140
#> [85] 0.7387964 0.7472788 0.7552140 0.7636964 0.7719052 0.7803876 0.7885964
#> [92] 0.7970788 0.8055612 0.8137700 0.8222525 0.8304613
#> 
#> 
#> $history
#>             ds     y floor          t  y_scaled
#>         <POSc> <num> <num>      <num>     <num>
#>  1: 1949-01-01   112     0 0.00000000 0.2711864
#>  2: 1949-02-01   118     0 0.01072293 0.2857143
#>  3: 1949-03-01   132     0 0.02040816 0.3196126
#>  4: 1949-04-01   129     0 0.03113110 0.3123487
#>  5: 1949-05-01   121     0 0.04150813 0.2929782
#>  6: 1949-06-01   135     0 0.05223106 0.3268765
#>  7: 1949-07-01   148     0 0.06260809 0.3583535
#>  8: 1949-08-01   148     0 0.07333103 0.3583535
#>  9: 1949-09-01   136     0 0.08405396 0.3292978
#> 10: 1949-10-01   119     0 0.09443099 0.2881356
#> 11: 1949-11-01   104     0 0.10515393 0.2518160
#> 12: 1949-12-01   118     0 0.11553096 0.2857143
#> 13: 1950-01-01   115     0 0.12625389 0.2784504
#> 14: 1950-02-01   126     0 0.13697682 0.3050847
#> 15: 1950-03-01   141     0 0.14666205 0.3414044
#> 16: 1950-04-01   135     0 0.15738499 0.3268765
#> 17: 1950-05-01   125     0 0.16776202 0.3026634
#> 18: 1950-06-01   149     0 0.17848495 0.3607748
#> 19: 1950-07-01   170     0 0.18886199 0.4116223
#> 20: 1950-08-01   170     0 0.19958492 0.4116223
#> 21: 1950-09-01   158     0 0.21030785 0.3825666
#> 22: 1950-10-01   133     0 0.22068488 0.3220339
#> 23: 1950-11-01   114     0 0.23140782 0.2760291
#> 24: 1950-12-01   140     0 0.24178485 0.3389831
#> 25: 1951-01-01   145     0 0.25250778 0.3510896
#> 26: 1951-02-01   150     0 0.26323072 0.3631961
#> 27: 1951-03-01   178     0 0.27291595 0.4309927
#> 28: 1951-04-01   163     0 0.28363888 0.3946731
#> 29: 1951-05-01   172     0 0.29401591 0.4164649
#> 30: 1951-06-01   178     0 0.30473884 0.4309927
#> 31: 1951-07-01   199     0 0.31511588 0.4818402
#> 32: 1951-08-01   199     0 0.32583881 0.4818402
#> 33: 1951-09-01   184     0 0.33656174 0.4455206
#> 34: 1951-10-01   162     0 0.34693878 0.3922518
#> 35: 1951-11-01   146     0 0.35766171 0.3535109
#> 36: 1951-12-01   166     0 0.36803874 0.4019370
#> 37: 1952-01-01   171     0 0.37876167 0.4140436
#> 38: 1952-02-01   180     0 0.38948461 0.4358354
#> 39: 1952-03-01   193     0 0.39951574 0.4673123
#> 40: 1952-04-01   181     0 0.41023867 0.4382567
#> 41: 1952-05-01   183     0 0.42061570 0.4430993
#> 42: 1952-06-01   218     0 0.43133864 0.5278450
#> 43: 1952-07-01   230     0 0.44171567 0.5569007
#> 44: 1952-08-01   242     0 0.45243860 0.5859564
#> 45: 1952-09-01   209     0 0.46316154 0.5060533
#> 46: 1952-10-01   191     0 0.47353857 0.4624697
#> 47: 1952-11-01   172     0 0.48426150 0.4164649
#> 48: 1952-12-01   194     0 0.49463853 0.4697337
#> 49: 1953-01-01   196     0 0.50536147 0.4745763
#> 50: 1953-02-01   196     0 0.51608440 0.4745763
#> 51: 1953-03-01   236     0 0.52576963 0.5714286
#> 52: 1953-04-01   235     0 0.53649256 0.5690073
#> 53: 1953-05-01   229     0 0.54686960 0.5544794
#> 54: 1953-06-01   243     0 0.55759253 0.5883777
#> 55: 1953-07-01   264     0 0.56796956 0.6392252
#> 56: 1953-08-01   272     0 0.57869249 0.6585956
#> 57: 1953-09-01   237     0 0.58941543 0.5738499
#> 58: 1953-10-01   211     0 0.59979246 0.5108959
#> 59: 1953-11-01   180     0 0.61051539 0.4358354
#> 60: 1953-12-01   201     0 0.62089242 0.4866828
#> 61: 1954-01-01   204     0 0.63161536 0.4939467
#> 62: 1954-02-01   188     0 0.64233829 0.4552058
#> 63: 1954-03-01   235     0 0.65202352 0.5690073
#> 64: 1954-04-01   227     0 0.66274645 0.5496368
#> 65: 1954-05-01   234     0 0.67312349 0.5665860
#> 66: 1954-06-01   264     0 0.68384642 0.6392252
#> 67: 1954-07-01   302     0 0.69422345 0.7312349
#> 68: 1954-08-01   293     0 0.70494639 0.7094431
#> 69: 1954-09-01   259     0 0.71566932 0.6271186
#> 70: 1954-10-01   229     0 0.72604635 0.5544794
#> 71: 1954-11-01   203     0 0.73676928 0.4915254
#> 72: 1954-12-01   229     0 0.74714632 0.5544794
#> 73: 1955-01-01   242     0 0.75786925 0.5859564
#> 74: 1955-02-01   233     0 0.76859218 0.5641646
#> 75: 1955-03-01   267     0 0.77827741 0.6464891
#> 76: 1955-04-01   269     0 0.78900035 0.6513317
#> 77: 1955-05-01   270     0 0.79937738 0.6537530
#> 78: 1955-06-01   315     0 0.81010031 0.7627119
#> 79: 1955-07-01   364     0 0.82047734 0.8813559
#> 80: 1955-08-01   347     0 0.83120028 0.8401937
#> 81: 1955-09-01   312     0 0.84192321 0.7554479
#> 82: 1955-10-01   274     0 0.85230024 0.6634383
#> 83: 1955-11-01   237     0 0.86302318 0.5738499
#> 84: 1955-12-01   278     0 0.87340021 0.6731235
#> 85: 1956-01-01   284     0 0.88412314 0.6876513
#> 86: 1956-02-01   277     0 0.89484607 0.6707022
#> 87: 1956-03-01   317     0 0.90487721 0.7675545
#> 88: 1956-04-01   313     0 0.91560014 0.7578692
#> 89: 1956-05-01   318     0 0.92597717 0.7699758
#> 90: 1956-06-01   374     0 0.93670010 0.9055690
#> 91: 1956-07-01   413     0 0.94707714 1.0000000
#> 92: 1956-08-01   405     0 0.95780007 0.9806295
#> 93: 1956-09-01   355     0 0.96852300 0.8595642
#> 94: 1956-10-01   306     0 0.97890003 0.7409201
#> 95: 1956-11-01   271     0 0.98962297 0.6561743
#> 96: 1956-12-01   306     0 1.00000000 0.7409201
#>             ds     y floor          t  y_scaled
#>         <POSc> <num> <num>      <num>     <num>
#> 
#> $history.dates
#>  [1] "1949-01-01 GMT" "1949-02-01 GMT" "1949-03-01 GMT" "1949-04-01 GMT"
#>  [5] "1949-05-01 GMT" "1949-06-01 GMT" "1949-07-01 GMT" "1949-08-01 GMT"
#>  [9] "1949-09-01 GMT" "1949-10-01 GMT" "1949-11-01 GMT" "1949-12-01 GMT"
#> [13] "1950-01-01 GMT" "1950-02-01 GMT" "1950-03-01 GMT" "1950-04-01 GMT"
#> [17] "1950-05-01 GMT" "1950-06-01 GMT" "1950-07-01 GMT" "1950-08-01 GMT"
#> [21] "1950-09-01 GMT" "1950-10-01 GMT" "1950-11-01 GMT" "1950-12-01 GMT"
#> [25] "1951-01-01 GMT" "1951-02-01 GMT" "1951-03-01 GMT" "1951-04-01 GMT"
#> [29] "1951-05-01 GMT" "1951-06-01 GMT" "1951-07-01 GMT" "1951-08-01 GMT"
#> [33] "1951-09-01 GMT" "1951-10-01 GMT" "1951-11-01 GMT" "1951-12-01 GMT"
#> [37] "1952-01-01 GMT" "1952-02-01 GMT" "1952-03-01 GMT" "1952-04-01 GMT"
#> [41] "1952-05-01 GMT" "1952-06-01 GMT" "1952-07-01 GMT" "1952-08-01 GMT"
#> [45] "1952-09-01 GMT" "1952-10-01 GMT" "1952-11-01 GMT" "1952-12-01 GMT"
#> [49] "1953-01-01 GMT" "1953-02-01 GMT" "1953-03-01 GMT" "1953-04-01 GMT"
#> [53] "1953-05-01 GMT" "1953-06-01 GMT" "1953-07-01 GMT" "1953-08-01 GMT"
#> [57] "1953-09-01 GMT" "1953-10-01 GMT" "1953-11-01 GMT" "1953-12-01 GMT"
#> [61] "1954-01-01 GMT" "1954-02-01 GMT" "1954-03-01 GMT" "1954-04-01 GMT"
#> [65] "1954-05-01 GMT" "1954-06-01 GMT" "1954-07-01 GMT" "1954-08-01 GMT"
#> [69] "1954-09-01 GMT" "1954-10-01 GMT" "1954-11-01 GMT" "1954-12-01 GMT"
#> [73] "1955-01-01 GMT" "1955-02-01 GMT" "1955-03-01 GMT" "1955-04-01 GMT"
#> [77] "1955-05-01 GMT" "1955-06-01 GMT" "1955-07-01 GMT" "1955-08-01 GMT"
#> [81] "1955-09-01 GMT" "1955-10-01 GMT" "1955-11-01 GMT" "1955-12-01 GMT"
#> [85] "1956-01-01 GMT" "1956-02-01 GMT" "1956-03-01 GMT" "1956-04-01 GMT"
#> [89] "1956-05-01 GMT" "1956-06-01 GMT" "1956-07-01 GMT" "1956-08-01 GMT"
#> [93] "1956-09-01 GMT" "1956-10-01 GMT" "1956-11-01 GMT" "1956-12-01 GMT"
#> 
#> $train.holiday.names
#> NULL
#> 
#> $train.component.cols
#>    additive_terms yearly multiplicative_terms
#> 1               1      1                    0
#> 2               1      1                    0
#> 3               1      1                    0
#> 4               1      1                    0
#> 5               1      1                    0
#> 6               1      1                    0
#> 7               1      1                    0
#> 8               1      1                    0
#> 9               1      1                    0
#> 10              1      1                    0
#> 11              1      1                    0
#> 12              1      1                    0
#> 13              1      1                    0
#> 14              1      1                    0
#> 15              1      1                    0
#> 16              1      1                    0
#> 17              1      1                    0
#> 18              1      1                    0
#> 19              1      1                    0
#> 20              1      1                    0
#> 
#> $component.modes
#> $component.modes$additive
#> [1] "yearly"                    "additive_terms"           
#> [3] "extra_regressors_additive" "holidays"                 
#> 
#> $component.modes$multiplicative
#> [1] "multiplicative_terms"            "extra_regressors_multiplicative"
#> 
#> 
#> $fit.kwargs
#> list()
#> 
#> attr(,"class")
#> [1] "prophet" "list"   

# Importance method
if ("importance" %in% learner$properties) print(learner$importance())

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 1892.169 
```
