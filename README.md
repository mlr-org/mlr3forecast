
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
ff = Forecaster$new(lrn("regr.ranger"), 1:3)$train(task)
newdata = data.frame(passengers = rep(NA_real_, 3L))
prediction = ff$predict_newdata(newdata, task)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 447.8017
#>        2    NA 473.3637
#>        3    NA 486.9652
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 461.4039
#>        2   390 412.0604
#>        3   432 393.8162
prediction$score(measure)
#> regr.rmse 
#>  25.46126

ff = Forecaster$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  108.0431

resampling = rsmp("forecast_cv")
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  53.05832
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
ff = Forecaster$new(lrn("regr.ranger"), 1:3)$train(new_task)
prediction = ff$predict(new_task, 142:144)
prediction$score(measure)
#> regr.rmse 
#>  18.86887

row_ids = new_task$nrow - 0:2
ff$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 409.5521
#>        2   390 390.2928
#>        3   461 392.8769
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
ff$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 409.5521
#>        2    NA 390.2928
#>        3    NA 392.8769

resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  82.88035

resampling = rsmp("forecast_cv")
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>    44.645
```

### mlr3pipelines integration

``` r
ff = Forecaster$new(lrn("regr.ranger"), 1:3)
glrn = as_learner(graph %>>% ff)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(measure)
#> regr.rmse 
#>   32.7928
```

### Example: Forecasting electricity demand

``` r
library(data.table)
library(mlr3learners)
library(mlr3pipelines)

task = tsibbledata::vic_elec |>
  as.data.table() |>
  setnames(tolower) |>
  _[
    year(time) == 2014L,
    .(demand = sum(demand) / 1e3, temperature = max(temperature), holiday = any(holiday)),
    by = date
  ] |>
  as_task_fcst(target = "demand", index = "date")

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(year = FALSE, is_day = FALSE, hour = FALSE, minute = FALSE, second = FALSE)
  )
ff = Forecaster$new(lrn("regr.ranger"), 1:3)
glrn = as_learner(graph %>>% ff)$train(task)

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
#>        1    NA 187.1951
#>        2    NA 191.1492
#>        3    NA 184.2040
#>      ---   ---      ---
#>       12    NA 213.9886
#>       13    NA 217.0293
#>       14    NA 219.1662
```

### Global Forecasting

``` r
library(mlr3learners)
library(mlr3pipelines)
library(tsibble)
#> Registered S3 method overwritten by 'tsibble':
#>   method               from 
#>   as_tibble.grouped_df dplyr
#> 
#> Attaching package: 'tsibble'
#> The following object is masked from 'package:data.table':
#> 
#>     key
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, union

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
      week_of_year = FALSE, day_of_week = FALSE, day_of_month = FALSE, day_of_year = FALSE,
      is_day = FALSE, hour = FALSE, minute = FALSE, second = FALSE
    )
  )
task = graph$train(task)[[1L]]

ff = Forecaster$new(lrn("regr.ranger"), 1:3)$train(task)
prediction = ff$predict(task, 4460:4464)
prediction$score(measure)
#> regr.rmse 
#>  23554.31

# resampling = rsmp("forecast_holdout", ratio = 0.8)
# rr = resample(task, ff, resampling)
# rr$aggregate(measure)
```
