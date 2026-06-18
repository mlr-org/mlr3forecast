
# mlr3forecast

Extending mlr3 to time series forecasting.

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![RCMD
Check](https://github.com/mlr-org/mlr3forecast/actions/workflows/rcmdcheck.yaml/badge.svg)](https://github.com/mlr-org/mlr3forecast/actions/workflows/rcmdcheck.yaml)
[![CRAN
status](https://img.shields.io/badge/CRAN-not%20published-orange)](https://CRAN.R-project.org/package=mlr3forecast)
[![StackOverflow](https://img.shields.io/badge/stackoverflow-mlr3-orange.svg)](https://stackoverflow.com/questions/tagged/mlr3)
[![Mattermost](https://img.shields.io/badge/chat-mattermost-orange.svg)](https://lmmisld-lmu-stats-slds.srv.mwn.de/mlr_invite/)
<!-- badges: end -->

> This package is in an early stage of development and should be
> considered experimental. If you are interested in experimenting with
> it, we welcome your feedback!

## Installation

Install the development version from [GitHub](https://github.com/):

``` r
# install.packages("pak")
pak::pak("mlr-org/mlr3forecast")
```

## Usage

mlr3forecast extends the [mlr3](https://mlr-org.com/) ecosystem to time
series forecasting. It introduces a forecasting task, forecasting
learners, temporal resampling strategies, forecasting measures, and
feature-engineering pipe operators, so that forecasters behave like any
other mlr3 learner — ready for tuning, benchmarking, pipelines, and
ensembling.

At a glance, mlr3forecast provides:

- **Classical forecasters** wrapping forecast, smooth, prophet, and
  tscount (e.g. `fcst.arima`, `fcst.auto_arima`, `fcst.ets`,
  `fcst.theta`, `fcst.tbats`, `fcst.prophet`).
- **Machine learning forecasting** that turns any `regr` learner into a
  forecaster via lag features, with both **recursive** (one model
  applied iteratively) and **direct** (one model per horizon)
  strategies.
- **Forecasting tasks and temporal resamplings** (`fcst.holdout`,
  `fcst.cv`) that respect the order of observations, plus global
  (longitudinal) forecasting across many series.
- **Feature-engineering pipe operators** such as `fcst.lags`,
  `fcst.rolling`, `fcst.fourier`, `fcst.feasts`, and `fcst.tsfeats`.
- **Forecasting measures** including MASE, RMSSE, Pinball, Winkler,
  coverage, and MSIS.
- **Full mlr3 integration**: tuning with mlr3tuning, benchmarking,
  target transformations, and ensembling with mlr3pipelines.

For now the forecasting task and learner are restricted to time series
regression, but may be extended to classification in the future.

The examples below cover [classical](#classical-forecasters) and
[machine learning](#machine-learning-forecasters) forecasters;
[benchmarking, ensembling, and
tuning](#benchmarking-ensembling-and-tuning); [global
forecasting](#global-forecasting); and [custom
PipeOps](#custom-pipeops).

### Classical forecasters

Native forecasting learners are provided by packages such as forecast,
smooth, prophet, and tscount.

``` r
library(mlr3forecast)
library(mlr3pipelines)

task = tsk("airpassengers")
task
#> 
#> ── <TaskFcst> (144x1): Monthly Airline Passenger Numbers 1949-1960 ─────────────
#> • Target: passengers
#> • Properties: ordered
#> • Order by: month
#> • Frequency: month

# or plot the task
autoplot(task)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" alt="" width="100%" />

``` r

# train a forecast learner
learner = lrn("fcst.auto_arima")$train(task)
prediction = learner$predict(task, 140:144)
prediction
#> 
#> ── <PredictionRegr> for 5 observations: ────────────────────────────────────────
#>  row_ids truth response      month
#>      140   606 623.9219 1960-08-01
#>      141   508 513.8585 1960-09-01
#>      142   461 450.7762 1960-10-01
#>      143   390 410.8961 1960-11-01
#>      144   432 439.9462 1960-12-01
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  13.85518
```

To forecast beyond the observed data, `generate_newdata()` builds the
future rows (with missing targets) and `predict_newdata()` fills them
in:

``` r
# generate new data to forecast unseen data
newdata = generate_newdata(task, 12L)
head(newdata)
#>         month passengers
#> 1: 1961-01-01         NA
#> 2: 1961-02-01         NA
#> 3: 1961-03-01         NA
#> 4: 1961-04-01         NA
#> 5: 1961-05-01         NA
#> 6: 1961-06-01         NA
prediction = learner$predict_newdata(newdata, task)
prediction
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth response      month
#>        1    NA 445.6351 1961-01-01
#>        2    NA 420.3953 1961-02-01
#>        3    NA 449.1988 1961-03-01
#>      ---   ---      ---        ---
#>       10    NA 494.1275 1961-10-01
#>       11    NA 423.3336 1961-11-01
#>       12    NA 465.5085 1961-12-01
```

The `forecast()` helper combines these two steps, generating the future
rows and predicting them in a single call:

``` r
forecast(learner, task, 12L)
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth response      month
#>        1    NA 445.6351 1961-01-01
#>        2    NA 420.3953 1961-02-01
#>        3    NA 449.1988 1961-03-01
#>      ---   ---      ---        ---
#>       10    NA 494.1275 1961-10-01
#>       11    NA 423.3336 1961-11-01
#>       12    NA 465.5085 1961-12-01
```

Target transformations can be applied by wrapping the learner in
`ppl("targettrafo")`:

``` r
# add a target log transformation
learner = as_learner(ppl(
  "targettrafo",
  graph = lrn("fcst.auto_arima"),
  targetmutate.trafo = function(x) log(x),
  targetmutate.inverter = function(x) list(response = exp(x$response))
))
prediction = learner$train(task)$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  12.29896
```

Classical forecasters can also return a predictive distribution as
quantiles:

``` r
# works with quantile response
learner = lrn(
  "fcst.auto_arima",
  predict_type = "quantiles",
  quantiles = c(0.1, 0.15, 0.5, 0.85, 0.9),
  quantile_response = 0.5
)$train(task)
learner$predict_newdata(newdata, task)
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth     q0.1    q0.15     q0.5    q0.85     q0.9 response      month
#>        1    NA 430.8905 433.7106 445.6351 457.5595 460.3796 445.6351 1961-01-01
#>        2    NA 403.0907 406.4005 420.3953 434.3901 437.6999 420.3953 1961-02-01
#>        3    NA 429.7726 433.4882 449.1988 464.9093 468.6249 449.1988 1961-03-01
#>      ---   ---      ---      ---      ---      ---      ---      ---        ---
#>       10    NA 469.8626 474.5036 494.1275 513.7514 518.3925 494.1275 1961-10-01
#>       11    NA 398.8383 403.5234 423.3336 443.1438 447.8290 423.3336 1961-11-01
#>       12    NA 440.8230 445.5445 465.5085 485.4725 490.1940 465.5085 1961-12-01
```

Forecasting resamplings respect the temporal order of the observations:

``` r
# resampling
learner = lrn("fcst.auto_arima")
resampling = rsmp("fcst.holdout", ratio = 0.7)
rr = resample(task, learner, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>   27.1211
```

### Machine learning forecasters

Any regression learner can be turned into a forecaster with
`as_learner_fcst()`, which adds lag features and forecasts recursively
by default:

``` r
library(mlr3learners)

task = tsk("airpassengers")
learner = lrn("regr.ranger")
flrn = as_learner_fcst(learner, lags = 1:12)$train(task)
newdata = generate_newdata(task, 12L)
prediction = flrn$predict_newdata(newdata, task)
prediction
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth response      month
#>        1    NA 440.3925 1961-01-01
#>        2    NA 439.5970 1961-02-01
#>        3    NA 465.6388 1961-03-01
#>      ---   ---      ---        ---
#>       10    NA 483.6618 1961-10-01
#>       11    NA 447.4815 1961-11-01
#>       12    NA 449.8724 1961-12-01
prediction = flrn$predict(task, 140:144)
prediction
#> 
#> ── <PredictionRegr> for 5 observations: ────────────────────────────────────────
#>  row_ids truth response      month
#>      140   606 575.3211 1960-08-01
#>      141   508 502.7415 1960-09-01
#>      142   461 455.4089 1960-10-01
#>      143   390 415.4293 1960-11-01
#>      144   432 434.3927 1960-12-01
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  18.17955

flrn = as_learner_fcst(learner, lags = 1:12)
resampling = rsmp("fcst.holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  46.69854

resampling = rsmp("fcst.cv")
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  24.57373
```

#### Direct forecasting

By default `as_learner_fcst()` builds a recursive forecaster (one model,
applied iteratively). Pass `strategy = "direct"` together with
`horizons` to train one model per horizon — predictions then come
straight from each horizon’s model, with no error accumulation:

``` r
task = tsk("airpassengers")
flrn = as_learner_fcst(
  lrn("regr.ranger"),
  lags = 1:12,
  strategy = "direct",
  horizons = 12
)$train(task, 1:132)
flrn$predict(task, 133:144)$score(msr("regr.rmse"))
#> regr.rmse 
#>  69.20286
```

#### Feature engineering

Lag features can be combined with other transformations using
mlr3pipelines:

``` r
library(mlr3pipelines)

task = tsk("airpassengers")
task$set_col_roles("month", add = "feature")
graph = po("fcst.lags", lags = 1:12) %>>%
  po(
    "datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_year = FALSE,
      day_of_month = FALSE,
      day_of_week = FALSE
    )
  ) %>>%
  lrn("regr.ranger")
flrn = as_learner_fcst(graph)$train(task)
prediction = flrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  15.85541
```

Use `selector_fcst_lags()` to apply transformations only to the lag
features, e.g. log-transforming lags while leaving date features
untouched:

``` r
task = tsk("airpassengers")
task$set_col_roles("month", add = "feature")
graph = po("fcst.lags", lags = 1:12) %>>%
  po("colapply", applicator = log, affect_columns = selector_fcst_lags()) %>>%
  po(
    "datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_year = FALSE,
      day_of_month = FALSE,
      day_of_week = FALSE
    )
  ) %>>%
  lrn("regr.ranger")
flrn = as_learner_fcst(graph)$train(task)
prediction = flrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  14.64131
```

#### Target transformations

Target transformations can be applied by wrapping the forecast learner
in `ppl("targettrafo")`. The lags are created from the transformed
target and predictions are automatically inverted back to the original
scale:

``` r
task = tsk("airpassengers")
graph = po("fcst.lags", lags = 1:12) %>>% lrn("regr.ranger")
pipeline = ppl(
  "targettrafo",
  graph = as_learner_fcst(graph),
  targetmutate.trafo = function(x) log(x),
  targetmutate.inverter = function(x) list(response = exp(x$response))
)
learner = as_learner(pipeline)$train(task)
prediction = learner$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  16.01615
```

#### Exogenous covariates

Forecasting tasks can include exogenous covariates. Here electricity
demand is forecast from its own lags, calendar features, and external
regressors (temperature, holiday) supplied for the forecast horizon:

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsk("electricity")
task$set_col_roles("date", add = "feature")
graph = po("fcst.lags", lags = 1:3) %>>%
  po("datefeatures", param_vals = list(year = FALSE)) %>>%
  lrn("regr.ranger")
flrn = as_learner_fcst(graph)$train(task)

max_date = task$data()[.N, date]
newdata = data.table(
  date = max_date + 1:14,
  demand = rep(NA_real_, 14L),
  temperature = 26,
  holiday = c(TRUE, rep(FALSE, 13L))
)
prediction = flrn$predict_newdata(newdata, task)
prediction
#> 
#> ── <PredictionRegr> for 14 observations: ───────────────────────────────────────
#>  row_ids truth response       date
#>        1    NA 187909.3 2015-01-01
#>        2    NA 197064.0 2015-01-02
#>        3    NA 189993.3 2015-01-03
#>      ---   ---      ---        ---
#>       12    NA 222403.4 2015-01-12
#>       13    NA 226838.6 2015-01-13
#>       14    NA 227918.0 2015-01-14
```

### Benchmarking, ensembling, and tuning

#### Comparing classical and ML forecasters

ML forecasters declare `task_type = "fcst"`, so they can be benchmarked
side-by-side with classical learners on the same task in a single
`benchmark()` call:

``` r
task = tsk("airpassengers")
resampling = rsmp("fcst.holdout", ratio = 0.9)$instantiate(task)
n_test = length(resampling$test_set(1L))

learners = list(
  lrn("fcst.arima"),
  as_learner_fcst(lrn("regr.ranger"), lags = 1:12),
  as_learner_fcst(lrn("regr.ranger"), lags = 1:12, strategy = "direct", horizons = n_test)
)
design = benchmark_grid(task, learners, resampling)
bmr = benchmark(design)
bmr$aggregate(msr("regr.rmse"))[, .(learner_id, regr.rmse)]
#>               learner_id regr.rmse
#> 1:            fcst.arima 216.31005
#> 2: fcst.lags.regr.ranger  49.23079
#> 3:           regr.ranger  77.87676
```

#### Ensemble forecasting

Forecast learners produce regression predictions under the hood, so the
standard mlr3pipelines ensemble pattern works directly: branch to
several forecasters with `gunion()` and average their forecasts with
`po("regravg")`. This mirrors the idea behind the forecastHybrid
package, but with any mix of classical or ML learners.

``` r
task = tsk("airpassengers")

graph = gunion(list(
  po("learner", lrn("fcst.auto_arima"), id = "arima"),
  po("learner", lrn("fcst.ets"), id = "ets"),
  po("learner", lrn("fcst.theta"), id = "theta")
)) %>>%
  po("regravg")
flrn = as_learner(graph)$train(task)
forecast(flrn, task, 12L)
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth response
#>        1    NA 442.5050
#>        2    NA 427.6327
#>        3    NA 478.5120
#>      ---   ---      ---
#>       10    NA 471.2626
#>       11    NA 408.0117
#>       12    NA 455.0409
flrn$predict(task, 140:144)$score(msr("regr.rmse"))
#> regr.rmse 
#>  12.23143

# weight the members instead of averaging equally
graph$param_set$set_values(regravg.weights = c(0.5, 0.3, 0.2))
flrn = as_learner(graph)$train(task)
flrn$predict(task, 140:144)$score(msr("regr.rmse"))
#> regr.rmse 
#>  12.28049
```

#### Tuning a forecaster

Forecast learners are regular mlr3 learners, so they plug into the
standard [mlr3tuning](https://mlr3tuning.mlr-org.com/) machinery. Mark
hyperparameters with `to_tune()` and wrap the learner in an
`auto_tuner()`, using a forecasting resampling such as `fcst.holdout` or
`fcst.cv` to respect the temporal order:

``` r
library(mlr3tuning)

task = tsk("airpassengers")

# tune an ML forecaster
flrn = as_learner_fcst(lrn("regr.ranger"), lags = 1:12)
flrn$param_set$set_values(
  regr.ranger.mtry.ratio = to_tune(0.1, 1),
  regr.ranger.num.trees = to_tune(100, 500)
)
at = auto_tuner(
  tuner = tnr("random_search"),
  learner = flrn,
  resampling = rsmp("fcst.cv"),
  measure = msr("regr.rmse"),
  term_evals = 4
)
at$train(task)
at$tuning_result[, .(regr.ranger.mtry.ratio, regr.ranger.num.trees, regr.rmse)]
#>    regr.ranger.mtry.ratio regr.ranger.num.trees regr.rmse
#> 1:              0.7424221                   408  15.77842

# the AutoTuner is itself a learner: predict with the best configuration
at$predict(task, 142:144)$score(msr("regr.rmse"))
#> regr.rmse 
#>  7.552903
```

Classical forecasters tune the same way:

``` r
flrn = lrn("fcst.auto_arima")
flrn$param_set$set_values(stationary = to_tune(p_lgl()), seasonal = to_tune(p_lgl()))
at = auto_tuner(
  tuner = tnr("grid_search"),
  learner = flrn,
  resampling = rsmp("fcst.holdout", ratio = 0.8),
  measure = msr("regr.rmse")
)
at$train(task)
at$tuning_result[, .(stationary, seasonal, regr.rmse)]
#>    stationary seasonal regr.rmse
#> 1:      FALSE     TRUE  35.08279
```

### Global forecasting

In machine learning forecasting the difference between forecasting a
single time series and longitudinal data is often referred to as local
and global forecasting. A global model is trained jointly across many
series, identified by a `key`:

``` r
library(mlr3learners)
library(mlr3pipelines)
library(tsibble)

dt = setDT(tsibbledata::aus_livestock)
setnames(dt, tolower)
dt[, month := as.Date(month)]
dt = dt[, .(count = sum(count)), by = .(state, month)]
setorder(dt, state, month)
task = as_task_fcst(dt, id = "aus_livestock", target = "count", order = "month", key = "state", freq = "month")
task$set_col_roles("month", add = "feature")

graph = po("fcst.lags", lags = 1:12) %>>%
  po(
    "datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_week = FALSE,
      day_of_month = FALSE,
      day_of_year = FALSE
    )
  ) %>>%
  lrn("regr.ranger")

flrn = as_learner_fcst(graph)$train(task)
prediction = flrn$predict(task, 4460:4464)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  25822.07

resampling = rsmp("fcst.holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  105420.6
```

#### Global vs. local forecasting

A single global model can be compared against fitting one local model
per series:

``` r
retail = setDT(tsibbledata::aus_retail)
setnames(retail, tolower)
retail[, month := as.Date(month)]
vic = retail[state == "Victoria"]
vic[, let(state = NULL, `series id` = NULL)]
vic[, industry := as.factor(industry)]
vic_train = vic[month < as.Date("2015-01-01")]
vic_test = vic[month >= as.Date("2015-01-01")]

# global forecasting
task_train = as_task_fcst(
  vic_train,
  id = "aus_retail_vic",
  target = "turnover",
  order = "month",
  key = "industry",
  freq = "month"
)
task_test = as_task_fcst(
  vic_test,
  id = "aus_retail_vic",
  target = "turnover",
  order = "month",
  key = "industry",
  freq = "month"
)

learner = lrn("regr.ranger", verbose = FALSE)
flrn = as_learner_fcst(learner, lags = 1:12)$train(task_train)
prediction_global = flrn$predict(task_test)
prediction_global
#> 
#> ── <PredictionRegr> for 960 observations: ──────────────────────────────────────
#>  row_ids truth response                                 industry      month
#>        1 476.2 471.0376 Cafes, restaurants and catering services 2015-01-01
#>        2 422.0 458.3091 Cafes, restaurants and catering services 2015-02-01
#>        3 471.2 485.1451 Cafes, restaurants and catering services 2015-03-01
#>      ---   ---      ---                                      ---        ---
#>      958 359.2 414.5361                   Takeaway food services 2018-10-01
#>      959 354.9 416.5364                   Takeaway food services 2018-11-01
#>      960 393.2 418.9951                   Takeaway food services 2018-12-01
prediction_global$score(msr("regr.rmse"))
#> regr.rmse 
#>  84.04068

# local forecasting
prediction_local = map(split(vic, by = "industry", drop = TRUE), function(dt) {
  task_train = as_task_fcst(
    dt[month < as.Date("2015-01-01")],
    id = "aus_retail_vic_local",
    target = "turnover",
    order = "month",
    freq = "month"
  )
  task_test = as_task_fcst(
    dt[month >= as.Date("2015-01-01")],
    id = "aus_retail_vic_local",
    target = "turnover",
    order = "month",
    freq = "month"
  )
  flrn = as_learner_fcst(learner, lags = 1:12)$train(task_train)
  prediction = flrn$predict(task_test)
  prediction
})
do.call(c, prediction_local)$score(msr("regr.rmse"))
#> regr.rmse 
#>   96.0076
```

### Custom PipeOps

`PipeOpFcstLags` can be used standalone to inspect the lag features it
generates, or combined with other PipeOps in a graph:

``` r
library(mlr3learners)
library(mlr3pipelines)

# use PipeOpFcstLags standalone to inspect lag features
task = tsk("airpassengers")
pop = po("fcst.lags", lags = 1:12)
new_task = pop$train(list(task))[[1L]]
new_task$data()
#>      passengers passengers_lag_1 passengers_lag_2 passengers_lag_3
#>   1:        112               NA               NA               NA
#>   2:        118              112               NA               NA
#>   3:        132              118              112               NA
#>   4:        129              132              118              112
#>   5:        121              129              132              118
#>  ---                                                              
#> 140:        606              622              535              472
#> 141:        508              606              622              535
#> 142:        461              508              606              622
#> 143:        390              461              508              606
#> 144:        432              390              461              508
#>      passengers_lag_4 passengers_lag_5 passengers_lag_6 passengers_lag_7
#>   1:               NA               NA               NA               NA
#>   2:               NA               NA               NA               NA
#>   3:               NA               NA               NA               NA
#>   4:               NA               NA               NA               NA
#>   5:              112               NA               NA               NA
#>  ---                                                                    
#> 140:              461              419              391              417
#> 141:              472              461              419              391
#> 142:              535              472              461              419
#> 143:              622              535              472              461
#> 144:              606              622              535              472
#>      passengers_lag_8 passengers_lag_9 passengers_lag_10 passengers_lag_11
#>   1:               NA               NA                NA                NA
#>   2:               NA               NA                NA                NA
#>   3:               NA               NA                NA                NA
#>   4:               NA               NA                NA                NA
#>   5:               NA               NA                NA                NA
#>  ---                                                                      
#> 140:              405              362               407               463
#> 141:              417              405               362               407
#> 142:              391              417               405               362
#> 143:              419              391               417               405
#> 144:              461              419               391               417
#>      passengers_lag_12
#>   1:                NA
#>   2:                NA
#>   3:                NA
#>   4:                NA
#>   5:                NA
#>  ---                  
#> 140:               559
#> 141:               463
#> 142:               407
#> 143:               362
#> 144:               405

# combine lags with date features in a single graph
graph = po("fcst.lags", lags = 1:12) %>>%
  po(
    "datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_week = FALSE,
      day_of_month = FALSE,
      day_of_year = FALSE
    )
  ) %>>%
  lrn("regr.ranger")
flrn = as_learner_fcst(graph)$train(task)
prediction = flrn$predict(task, 133:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  17.88712

newdata = generate_newdata(task, 12L)
flrn$predict_newdata(newdata, task)
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth response      month
#>        1    NA 439.3669 1961-01-01
#>        2    NA 440.0438 1961-02-01
#>        3    NA 457.0727 1961-03-01
#>      ---   ---      ---        ---
#>       10    NA 479.3021 1961-10-01
#>       11    NA 446.6218 1961-11-01
#>       12    NA 447.1091 1961-12-01
```
