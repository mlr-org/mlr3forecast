
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
measure = msr("regr.rmse")
flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)$train(task)
newdata = data.frame(passengers = rep(NA_real_, 3L))
prediction = flrn$predict_newdata(newdata, task)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 437.1837
#>        2    NA 438.4461
#>        3    NA 459.7955
prediction = flrn$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 459.4802
#>        2   390 410.1595
#>        3   432 431.6638
prediction$score(measure)
#> regr.rmse 
#>  11.67375

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)
resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  47.67586

resampling = rsmp("forecast_cv")
rr = resample(task, flrn, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  24.16082
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
prediction$score(measure)
#> regr.rmse 
#>   13.4413

row_ids = new_task$nrow - 0:2
flrn$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 434.2353
#>        2   390 431.9932
#>        3   461 456.3106
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
flrn$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 434.2353
#>        2    NA 431.9932
#>        3    NA 456.3106

resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(new_task, flrn, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  48.93365

resampling = rsmp("forecast_cv")
rr = resample(new_task, flrn, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  25.04447
```

### mlr3pipelines integration

``` r
flrn = ForecastLearner$new(lrn("regr.ranger"), 1:12)
glrn = as_learner(graph %>>% flrn)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(measure)
#> regr.rmse 
#>  13.36275
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
#>        1    NA 186.8375
#>        2    NA 191.9585
#>        3    NA 184.0513
#>      ---   ---      ---
#>       12    NA 215.1711
#>       13    NA 218.9118
#>       14    NA 219.7826
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

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)$train(task)
prediction = flrn$predict(task, 4460:4464)
prediction$score(measure)
#> regr.rmse 
#>  21451.45

flrn = ForecastLearner$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.9)
rr = resample(task, flrn, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  77934.44
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
prediction$score(measure)
#> regr.rmse 
#>  33069.46

# global forecasting
task = tsibbledata::aus_livestock |>
  as.data.table() |>
  setnames(tolower) |>
  _[, month := as.Date(month)] |>
  _[, .(count = sum(count)), by = .(state, month)] |>
  setorder(state, month) |>
  as_task_fcst(target = "count", index = "month", key = "state")
task = graph$train(task)[[1L]]
flrn = ForecastLearner$new(lrn("regr.ranger"), 1L)$train(task)
tab = task$backend$data(
  rows = task$row_ids, cols = c(task$backend$primary_key, "month.year", "state")
)
setnames(tab, c("row_id", "year", "state"))
row_ids = tab[year >= 2015 & state == "Western Australia", row_id]
prediction = flrn$predict(task, row_ids)
prediction$score(measure)
#> regr.rmse 
#>  31124.47
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
