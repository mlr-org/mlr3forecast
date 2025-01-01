
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
#>        1    NA 452.7575
#>        2    NA 474.8485
#>        3    NA 481.4720
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 458.1226
#>        2   390 412.7669
#>        3   432 396.2460
prediction$score(measure)
#> regr.rmse 
#>  24.52863

ff = Forecaster$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  112.7031

resampling = rsmp("forecast_cv")
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  48.80621
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
#>  19.26131

row_ids = new_task$nrow - 0:2
ff$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 407.1069
#>        2   390 391.4622
#>        3   461 393.6115
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
ff$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 407.1069
#>        2    NA 391.4622
#>        3    NA 393.6115

resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  81.82989

resampling = rsmp("forecast_cv")
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  45.80208
```

### mlr3pipelines integration

``` r
ff = Forecaster$new(lrn("regr.ranger"), 1:3)
glrn = as_learner(graph %>>% ff)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(measure)
#> regr.rmse 
#>  34.39579
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
#>        1    NA 187.1619
#>        2    NA 191.8612
#>        3    NA 184.2280
#>      ---   ---      ---
#>       12    NA 214.1141
#>       13    NA 216.5287
#>       14    NA 217.9717
```
