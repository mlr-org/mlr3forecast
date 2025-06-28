
# mlr3forecast

Extending mlr3 to time series forecasting.

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![RCMD
Check](https://github.com/mlr-org/mlr3forecast/actions/workflows/rcmdcheck.yaml/badge.svg)](https://github.com/mlr-org/mlr3forecast/actions/workflows/rcmdcheck.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/mlr3forecast)](https://CRAN.R-project.org/package=mlr3forecast)
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

The goal of mlr3forecast is to extend mlr3 to time series forecasting.
This is achieved by introducing new classes and methods for forecasting
tasks, learners, and resamplers. For now the forecasting task and
learner is restricted to time series regression tasks, but might be
extended to classification tasks in the future.

We have two goals, one to support traditional forecasting learners and
the other to support machine learning forecasting, i.e. using regression
learners and applying them to forecasting tasks. The design of the
latter is still in flux and may change.

### Example: forecasting with forecast learner

Currently, we support native forecasting learners from the forecast
package. In the future, we plan to support more forecasting learners.

``` r
library(mlr3forecast)

task = tsk("airpassengers")
task
#> 
#> ── <TaskFcst> (144x1): Monthly Airline Passenger Numbers 1949-1960 ─────────────
#> • Target: passengers
#> • Properties: ordered
#> • Order by: month
#> • Frequency: monthly

# or plot the task
autoplot(task)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

``` r

learner = lrn("fcst.auto_arima")$train(task)
prediction = learner$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  13.85518

# generate new data to forecast unseen data
newdata = generate_newdata(task, 12L)
newdata
#>          month passengers
#>  1: 1961-01-01         NA
#>  2: 1961-02-01         NA
#>  3: 1961-03-01         NA
#>  4: 1961-04-01         NA
#>  5: 1961-05-01         NA
#>  6: 1961-06-01         NA
#>  7: 1961-07-01         NA
#>  8: 1961-08-01         NA
#>  9: 1961-09-01         NA
#> 10: 1961-10-01         NA
#> 11: 1961-11-01         NA
#> 12: 1961-12-01         NA
learner$predict_newdata(newdata, task)
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth response
#>        1    NA 445.6351
#>        2    NA 420.3953
#>        3    NA 449.1988
#>      ---   ---      ---
#>       10    NA 494.1275
#>       11    NA 423.3336
#>       12    NA 465.5085

# works with quantile response
learner = lrn("fcst.auto_arima",
  predict_type = "quantiles",
  quantiles = c(0.1, 0.15, 0.5, 0.85, 0.9),
  quantile_response = 0.5
)$train(task)
learner$predict_newdata(newdata, task)
#> 
#> ── <PredictionRegr> for 12 observations: ───────────────────────────────────────
#>  row_ids truth     q0.1    q0.15     q0.5    q0.85     q0.9 response
#>        1    NA 430.8905 433.7106 445.6351 457.5595 460.3796 445.6351
#>        2    NA 403.0907 406.4005 420.3953 434.3901 437.6999 420.3953
#>        3    NA 429.7726 433.4882 449.1988 464.9093 468.6249 449.1988
#>      ---   ---      ---      ---      ---      ---      ---      ---
#>       10    NA 469.8626 474.5036 494.1275 513.7514 518.3925 494.1275
#>       11    NA 398.8383 403.5234 423.3336 443.1438 447.8290 423.3336
#>       12    NA 440.8230 445.5445 465.5085 485.4725 490.1940 465.5085
```

### Example: forecasting with regression learner

``` r
library(mlr3learners)

task = tsk("airpassengers")
learner = lrn("regr.ranger")
flrn = ForecastLearner$new(learner, lags = 1:12)$train(task)
newdata = generate_newdata(task, 3L)
prediction = flrn$predict_newdata(newdata, task)
prediction
#> 
#> ── <PredictionRegr> for 3 observations: ────────────────────────────────────────
#>  row_ids truth response
#>        1    NA 437.1598
#>        2    NA 433.9036
#>        3    NA 455.5044
prediction = flrn$predict(task, 142:144)
prediction
#> 
#> ── <PredictionRegr> for 3 observations: ────────────────────────────────────────
#>  row_ids truth response
#>        1   461 459.6533
#>        2   390 412.1005
#>        3   432 432.9565
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>   12.7953

flrn = ForecastLearner$new(learner, lags = 1:12)
resampling = rsmp("fcst.holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  48.42478

resampling = rsmp("fcst.cv")
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  24.28508
```

Or with some feature engineering using mlr3pipelines:

``` r
library(mlr3pipelines)

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_year = FALSE,
      day_of_month = FALSE,
      day_of_week = FALSE,
      is_day = FALSE,
      hour = FALSE,
      minute = FALSE,
      second = FALSE
    )
  )
task = tsk("airpassengers")
task$set_col_roles("month", add = "feature")
flrn = ForecastLearner$new(lrn("regr.ranger"), lags = 1:12)
glrn = as_learner(graph %>>% flrn)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  13.48036
```

### Example: forecasting electricity demand

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsk("electricity")
task$set_col_roles("date", add = "feature")
graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      year = FALSE,
      is_day = FALSE,
      hour = FALSE,
      minute = FALSE,
      second = FALSE
    )
  )
flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)
glrn = as_learner(graph %>>% flrn)$train(task)

max_date = task$data()[.N, date]
newdata = data.frame(
  date = max_date + 1:14,
  demand = rep(NA_real_, 14L),
  temperature = 26,
  holiday = c(TRUE, rep(FALSE, 13L))
)
prediction = glrn$predict_newdata(newdata, task)
prediction
#> 
#> ── <PredictionRegr> for 14 observations: ───────────────────────────────────────
#>  row_ids truth response
#>        1    NA 187479.9
#>        2    NA 196534.3
#>        3    NA 188444.0
#>      ---   ---      ---
#>       12    NA 219925.8
#>       13    NA 223201.3
#>       14    NA 225661.7
```

### Example: global forecasting (longitudinal data)

``` r
library(mlr3learners)
library(mlr3pipelines)
library(tsibble)

task = tsibbledata::aus_livestock |>
  as.data.table() |>
  setnames(tolower) |>
  _[, month := as.Date(month)] |>
  _[, .(count = sum(count)), by = .(state, month)] |>
  setorder(state, month) |>
  as_task_fcst(
    id = "aus_livestock",
    target = "count",
    order = "month",
    key = "state",
    freq = "monthly"
  )
task$set_col_roles("month", add = "feature")

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_week = FALSE,
      day_of_month = FALSE,
      day_of_year = FALSE,
      is_day = FALSE,
      hour = FALSE,
      minute = FALSE,
      second = FALSE
    )
  )
task = graph$train(task)[[1L]]

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)$train(task)
prediction = flrn$predict(task, 4460:4464)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  22262.08

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("fcst.holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  90543.39
```

### Example: global vs local forecasting

In machine learning forecasting the difference between forecasting a
time series and longitudinal data is often refered to local and global
forecasting.

``` r
# TODO: find better task example, since the effect is minor here

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_week = FALSE,
      day_of_month = FALSE,
      day_of_year = FALSE,
      is_day = FALSE,
      hour = FALSE,
      minute = FALSE,
      second = FALSE
    )
  )

# local forecasting
task = tsibbledata::aus_livestock |>
  as.data.table() |>
  setnames(tolower) |>
  _[, month := as.Date(month)] |>
  _[state == "Western Australia", .(count = sum(count)), by = .(month)] |>
  setorder(month) |>
  as_task_fcst(id = "aus_livestock", target = "count", order = "month")
task = graph$train(task)[[1L]]
flrn = ForecastLearner$new(lrn("regr.ranger"), 1L)$train(task)
tab = task$backend$data(
  rows = task$row_ids,
  cols = c(task$backend$primary_key, "month.year")
)
setnames(tab, c("row_id", "year"))
row_ids = tab[year >= 2015, row_id]
prediction = flrn$predict(task, row_ids)
prediction$score(msr("regr.rmse"))

# global forecasting
task = tsibbledata::aus_livestock |>
  as.data.table() |>
  setnames(tolower) |>
  _[, month := as.Date(month)] |>
  _[, .(count = sum(count)), by = .(state, month)] |>
  setorder(state, month) |>
  as_task_fcst(id = "aus_livestock", target = "count", order = "month", key = "state")
task = graph$train(task)[[1L]]
task$col_roles$key = "state"
flrn = ForecastLearner$new(lrn("regr.ranger"), 1L)$train(task)
tab = task$backend$data(
  rows = task$row_ids,
  cols = c(task$backend$primary_key, "month.year", "state")
)
setnames(tab, c("row_id", "year", "state"))
row_ids = tab[year >= 2015 & state == "Western Australia", row_id]
prediction = flrn$predict(task, row_ids)
prediction$score(msr("regr.rmse"))
```

### Example: Custom PipeOps

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsk("airpassengers")
pop = po("fcst.lag", lags = 1:12)
new_task = pop$train(list(task))[[1L]]
new_task$data()

task = tsk("airpassengers")
graph = po("fcst.lag", lags = 1:12) %>>%
  ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_week = FALSE,
      day_of_month = FALSE,
      day_of_year = FALSE,
      is_day = FALSE,
      hour = FALSE,
      minute = FALSE,
      second = FALSE
    )
  )
flrn = ForecastLearnerManual$new(lrn("regr.ranger"))
glrn = as_learner(graph %>>% flrn)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))

newdata = generate_newdata(task, 12L)
glrn$predict_newdata(newdata, task)
```

### Example: common target transformations

Some common target transformations in forecasting are:

- differencing (WIP)
- log transformation, see example below
- power transformations such as
  [Box-Cox](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_boxcox.html)
  and
  [Yeo-Johnson](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_yeojohnson.html)
  currently only supported as feature transformation and not target
- scaling/normalization, available see
  [here](https://mlr3pipelines.mlr-org.com/reference/mlr_pipeops_targettrafoscalerange.html)

``` r
trafo = po("targetmutate",
  param_vals = list(
    trafo = function(x) log(x),
    inverter = function(x) list(response = exp(x$response))
  )
)

graph = po("fcst.lag", lags = 1:12) %>>%
  ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_week = FALSE,
      day_of_month = FALSE,
      day_of_year = FALSE,
      is_day = FALSE,
      hour = FALSE,
      minute = FALSE,
      second = FALSE
    )
  )

task = tsk("airpassengers")
flrn = ForecastLearnerManual$new(lrn("regr.ranger"))
glrn = as_learner(graph %>>% flrn)
pipeline = ppl("targettrafo", graph = glrn, trafo_pipeop = trafo)
glrn = as_learner(pipeline)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
```

``` r
graph = po("fcst.lag", lags = 1:12) %>>%
  ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE,
      day_of_week = FALSE,
      day_of_month = FALSE,
      day_of_year = FALSE,
      is_day = FALSE,
      hour = FALSE,
      minute = FALSE,
      second = FALSE
    )
  )

task = tsk("airpassengers")
flrn = ForecastLearnerManual$new(lrn("regr.ranger"))
glrn = as_learner(graph %>>% flrn)
trafo = po("fcst.targetdiff", lags = 12L)
pipeline = ppl("targettrafo", graph = glrn, trafo_pipeop = trafo)
glrn = as_learner(pipeline)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
```
