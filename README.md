
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

> [!IMPORTANT]
> This package is in an early stage of development and should be considered experimental.
> If you are interested in experimenting with it, we welcome your feedback!

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
the other to support to support machine learning forecasting, i.e. using
regression learners and applying them to forecasting tasks. The design
of the latter is still in flux and may change.

### Example: native forecast learner

First lets create a helper function to generate new data for forecasting
tasks.

``` r
library(mlr3forecast)
#> Loading required package: mlr3

generate_newdata = function(task, n = 1L, resolution = "day") {
  assert_count(n)
  assert_string(resolution)
  assert_choice(
    resolution, c("second", "minute", "hour", "day", "week", "month", "quarter", "year")
  )

  order_cols = task$col_roles$order
  max_index = max(task$data(cols = order_cols)[[1L]])

  unit = switch(resolution,
    second = "sec",
    minute = "min",
    hour = ,
    day = ,
    week = ,
    month = ,
    quarter = ,
    year = identity(resolution),
    stopf("Invalid resolution")
  )
  unit = sprintf("1 %s", unit)
  index = seq(max_index, length.out = n + 1L, by = unit)
  index = index[2:length(index)]

  newdata = data.frame(index = index, target = rep(NA_real_, n), check.names = FALSE)
  setNames(newdata, c(order_cols, task$target_names))
}

task = tsk("airpassengers")
newdata = generate_newdata(task, 12L, "month")
newdata
#>          date passengers
#> 1  1961-01-01         NA
#> 2  1961-02-01         NA
#> 3  1961-03-01         NA
#> 4  1961-04-01         NA
#> 5  1961-05-01         NA
#> 6  1961-06-01         NA
#> 7  1961-07-01         NA
#> 8  1961-08-01         NA
#> 9  1961-09-01         NA
#> 10 1961-10-01         NA
#> 11 1961-11-01         NA
#> 12 1961-12-01         NA
```

Currently, we support native forecasting learners from the forecast
package. In the future, we plan to support more forecasting learners.

``` r
task = tsk("airpassengers")
learner = lrn("fcst.arima", order = c(2L, 1L, 2L))$train(task)
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo
prediction = learner$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  50.62826
newdata = generate_newdata(task, 12L, "month")
learner$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth response
#>        1    NA 483.8637
#>        2    NA 465.9727
#>        3    NA 469.4676
#>      ---   ---      ---
#>       10    NA 466.3308
#>       11    NA 466.2953
#>       12    NA 466.2723

learner = lrn("fcst.auto_arima")$train(task)
prediction = learner$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  39.62379
newdata = generate_newdata(task, 12L, "month")
learner$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth response
#>        1    NA 483.3799
#>        2    NA 490.9993
#>        3    NA 520.2773
#>      ---   ---      ---
#>       10    NA 500.2729
#>       11    NA 507.3034
#>       12    NA 512.9829

# works with quantile response
learner = lrn("fcst.auto_arima",
  predict_type = "quantiles",
  quantiles = c(0.1, 0.15, 0.5, 0.85, 0.9),
  quantile_response = 0.5
)$train(task)
learner$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth     q0.1    q0.15     q0.5    q0.85     q0.9 response
#>        1    NA 449.3201 455.8346 483.3799 510.9252 517.4397 483.3799
#>        2    NA 439.6752 449.4918 490.9993 532.5069 542.3235 490.9993
#>        3    NA 464.0693 474.8200 520.2773 565.7347 576.4854 520.2773
#>      ---   ---      ---      ---      ---      ---      ---      ---
#>       10    NA 440.1583 451.6562 500.2729 548.8896 560.3875 500.2729
#>       11    NA 446.7823 458.3580 507.3034 556.2489 567.8246 507.3034
#>       12    NA 452.1168 463.7584 512.9829 562.2074 573.8491 512.9829
```

### machine learning forecasting

``` r
library(mlr3learners)

task = tsk("airpassengers")
task$select(setdiff(task$feature_names, "date"))
flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)$train(task)
newdata = data.frame(passengers = rep(NA_real_, 3L))
prediction = flrn$predict_newdata(newdata, task)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 433.1747
#>        2    NA 434.1418
#>        3    NA 453.9637
prediction = flrn$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 457.6481
#>        2   390 407.7734
#>        3   432 429.5992
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  10.53394

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)
resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  49.04818

resampling = rsmp("forecast_cv")
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  28.13991
```

### Multivariate

``` r
library(mlr3pipelines)

task = tsk("airpassengers")
# datefeatures currently requires POSIXct
graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(is_day = FALSE, hour = FALSE, minute = FALSE, second = FALSE)
  )
new_task = graph$train(task)[[1L]]
flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)$train(new_task)
prediction = flrn$predict(new_task, 142:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  12.51686

row_ids = new_task$nrow - 0:2
flrn$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 433.6035
#>        2   390 428.3367
#>        3   461 455.9360
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
flrn$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 433.6035
#>        2    NA 428.3367
#>        3    NA 455.9360

resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(new_task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  50.17421

resampling = rsmp("forecast_cv")
rr = resample(new_task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  26.57583
```

### mlr3pipelines integration

``` r
graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(is_day = FALSE, hour = FALSE, minute = FALSE, second = FALSE)
  )
flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)
glrn = as_learner(graph %>>% flrn)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  14.72715
```

### Example: Forecasting electricity demand

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsibbledata::vic_elec |>
  as.data.table() |>
  setnames(tolower) |>
  _[
    year(time) == 2014L,
    .(
      demand = sum(demand) / 1e3,
      temperature = max(temperature),
      holiday = any(holiday)
    ),
    by = date
  ] |>
  as_task_fcst(id = "vic_elec", target = "demand", order = "date")

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      year = FALSE, is_day = FALSE, hour = FALSE, minute = FALSE, second = FALSE
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
#> <PredictionRegr> for 14 observations:
#>  row_ids truth response
#>        1    NA 186.9375
#>        2    NA 190.9916
#>        3    NA 184.2812
#>      ---   ---      ---
#>       12    NA 213.9659
#>       13    NA 217.8344
#>       14    NA 218.9379
```

### Global Forecasting

``` r
library(mlr3learners)
library(mlr3pipelines)
library(tsibble) # needs not be loaded for it to somehow work

task = tsibbledata::aus_livestock |>
  as.data.table() |>
  setnames(tolower) |>
  _[, month := as.Date(month)] |>
  _[, .(count = sum(count)), by = .(state, month)] |>
  setorder(state, month) |>
  as_task_fcst(id = "aus_livestock", target = "count", order = "month", key = "state")

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE, day_of_week = FALSE, day_of_month = FALSE,
      day_of_year = FALSE, is_day = FALSE, hour = FALSE, minute = FALSE,
      second = FALSE
    )
  )
task = graph$train(task)[[1L]]
task$col_roles$key = "state"

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)$train(task)
prediction = flrn$predict(task, 4460:4464)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  22959.84

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>   91961.9
```

### Example: Global vs Local Forecasting

In machine learning forecasting the difference between forecasting a
time series and longitudinal data is often refered to local and global
forecasting.

``` r
# TODO: find better task example, since the effect is minor here

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE, day_of_week = FALSE, day_of_month = FALSE,
      day_of_year = FALSE, is_day = FALSE, hour = FALSE, minute = FALSE,
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
  rows = task$row_ids, cols = c(task$backend$primary_key, "month.year")
)
setnames(tab, c("row_id", "year"))
row_ids = tab[year >= 2015, row_id]
prediction = flrn$predict(task, row_ids)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  32433.75

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
  rows = task$row_ids, cols = c(task$backend$primary_key, "month.year", "state")
)
setnames(tab, c("row_id", "year", "state"))
row_ids = tab[year >= 2015 & state == "Western Australia", row_id]
prediction = flrn$predict(task, row_ids)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>   30227.4
```

### Example: Custom PipeOps

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsk("airpassengers")
pop = po("fcst.lag", lag = 1:12)
new_task = pop$train(list(task))[[1L]]
new_task$data()
#>      passengers       date passengers_lag_1 passengers_lag_2 passengers_lag_3
#>   1:        112 1949-01-01               NA               NA               NA
#>   2:        118 1949-02-01              112               NA               NA
#>   3:        132 1949-03-01              118              112               NA
#>   4:        129 1949-04-01              132              118              112
#>   5:        121 1949-05-01              129              132              118
#>  ---                                                                         
#> 140:        606 1960-08-01              622              535              472
#> 141:        508 1960-09-01              606              622              535
#> 142:        461 1960-10-01              508              606              622
#> 143:        390 1960-11-01              461              508              606
#> 144:        432 1960-12-01              390              461              508
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

task = tsk("airpassengers")
graph = po("fcst.lag", lag = 1:12) %>>%
  ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE, day_of_week = FALSE, day_of_month = FALSE,
      day_of_year = FALSE, is_day = FALSE, hour = FALSE, minute = FALSE,
      second = FALSE
    )
  )
flrn = ForecastRecursiveLearner$new(lrn("regr.ranger"))
glrn = as_learner(graph %>>% flrn)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  25.34847

newdata = generate_newdata(task, 12L, "month")
glrn$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth response
#>        1    NA 436.1648
#>        2    NA 438.0083
#>        3    NA 453.3400
#>      ---   ---      ---
#>       10    NA 469.5736
#>       11    NA 439.0174
#>       12    NA 438.8632
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

graph = po("fcst.lag", lag = 1:12) %>>%
  ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE, day_of_week = FALSE, day_of_month = FALSE,
      day_of_year = FALSE, is_day = FALSE, hour = FALSE, minute = FALSE,
      second = FALSE
    )
  )

task = tsk("airpassengers")
flrn = ForecastRecursiveLearner$new(lrn("regr.ranger"))
glrn = as_learner(graph %>>% flrn)
pipeline = ppl("targettrafo", graph = glrn, trafo_pipeop = trafo)
glrn = as_learner(pipeline)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
```

``` r
graph = po("fcst.lag", lag = 1:12) %>>%
  ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(
      week_of_year = FALSE, day_of_week = FALSE, day_of_month = FALSE,
      day_of_year = FALSE, is_day = FALSE, hour = FALSE, minute = FALSE,
      second = FALSE
    )
  )

task = tsk("airpassengers")
flrn = ForecastRecursiveLearner$new(lrn("regr.ranger"))
glrn = as_learner(graph %>>% flrn)
trafo = po("fcst.targetdiff", lag = 12L)
pipeline = ppl("targettrafo", graph = glrn, trafo_pipeop = trafo)
glrn = as_learner(pipeline)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(msr("regr.rmse"))
```
