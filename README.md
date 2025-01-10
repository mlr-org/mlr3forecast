
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

### Univariate

``` r
library(mlr3forecast)
library(mlr3learners)

task = tsk("airpassengers")
task$select(setdiff(task$feature_names, "date"))
flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)$train(task)
newdata = data.frame(passengers = rep(NA_real_, 3L))
prediction = flrn$predict_newdata(newdata, task)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 436.4899
#>        2    NA 436.6391
#>        3    NA 456.0920
prediction = flrn$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 456.6918
#>        2   390 411.1894
#>        3   432 431.1121
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  12.49451

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)
resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  48.87653

resampling = rsmp("forecast_cv")
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  25.25769
```

### Multivariate

``` r
library(mlr3learners)
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
#>  13.44279

row_ids = new_task$nrow - 0:2
flrn$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 434.0366
#>        2   390 436.9707
#>        3   461 458.7455
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
flrn$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 434.0366
#>        2    NA 436.9707
#>        3    NA 458.7455

resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(new_task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  50.14024

resampling = rsmp("forecast_cv")
rr = resample(new_task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  26.23039
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
#>  13.82398
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
  as_task_fcst(target = "demand", index = "date")

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
#>        1    NA 186.6940
#>        2    NA 190.8129
#>        3    NA 183.0273
#>      ---   ---      ---
#>       12    NA 214.4948
#>       13    NA 218.4061
#>       14    NA 220.0571
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
  as_task_fcst(target = "count", index = "month", key = "state")

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
#>   22058.4

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(msr("regr.rmse"))
#> regr.rmse 
#>  94136.08
```

### Example: Global vs Local Forecasting

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
  as_task_fcst(target = "count", index = "month")
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
#>  33009.95

# global forecasting
task = tsibbledata::aus_livestock |>
  as.data.table() |>
  setnames(tolower) |>
  _[, month := as.Date(month)] |>
  _[, .(count = sum(count)), by = .(state, month)] |>
  setorder(state, month) |>
  as_task_fcst(target = "count", index = "month", key = "state")
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
#>  30965.86
```

### Example: generate new data

``` r
library(checkmate)

generate_newdata = function(task, n = 1L, resolution = "day") {
  assert_count(n)
  assert_string(resolution)
  assert_choice(
    resolution, c("second", "minute", "hour", "day", "week", "month", "quarter", "year")
  )

  order_cols = task$col_roles$order
  target = task$target_names
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

  newdata = data.table(index = index, target = rep(NA_real_, n))
  setnames(newdata, c(order_cols, target))
  setDF(newdata)[]
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

### Example: Native Forecasting Learners

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

task = tsk("airpassengers")
learner = lrn("fcst.arfima")$train(task)
prediction = learner$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  54.93583
newdata = generate_newdata(task, 12L, "month")
learner$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth response
#>        1    NA 470.3903
#>        2    NA 449.1027
#>        3    NA 452.4956
#>      ---   ---      ---
#>       10    NA 408.8267
#>       11    NA 405.3927
#>       12    NA 402.0429

task = tsk("airpassengers")
learner = lrn("fcst.ets")$train(task)
prediction = learner$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  61.44108
newdata = generate_newdata(task, 12L, "month")
learner$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth response
#>        1    NA 431.9958
#>        2    NA 431.9958
#>        3    NA 431.9958
#>      ---   ---      ---
#>       10    NA 431.9958
#>       11    NA 431.9958
#>       12    NA 431.9958

task = tsk("airpassengers")
learner = lrn("fcst.tbats")$train(task)
prediction = learner$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  40.89975
newdata = generate_newdata(task, 12L, "month")
learner$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth response
#>        1    NA 502.2486
#>        2    NA 545.0701
#>        3    NA 610.7134
#>      ---   ---      ---
#>       10    NA 592.3269
#>       11    NA 613.4432
#>       12    NA 633.9967

task = tsk("airpassengers")
learner = lrn("fcst.bats")$train(task)
prediction = learner$predict(task, 140:144)
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  40.89975
newdata = generate_newdata(task, 12L, "month")
learner$predict_newdata(newdata, task)
#> <PredictionRegr> for 12 observations:
#>  row_ids truth response
#>        1    NA 502.2486
#>        2    NA 545.0701
#>        3    NA 610.7134
#>      ---   ---      ---
#>       10    NA 592.3269
#>       11    NA 613.4432
#>       12    NA 633.9967
```

### Custom PipeOps

``` r
library(mlr3pipelines)

task = tsk("airpassengers")
pop = po("fcst.lags")
pop$train(list(task))[[1L]]
```
