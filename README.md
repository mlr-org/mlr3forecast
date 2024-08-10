
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
> considered experimental.

## Installation

Install the development version from [GitHub](https://github.com/):

``` r
# install.packages("pak")
pak::pak("mlr-org/mlr3forecast")
```

## Usage

``` r
library(mlr3forecast)
#> Loading required package: mlr3
library(mlr3learners)

dt = tsbox::ts_dt(AirPassengers)
dt[, time := NULL]
task = as_task_regr(dt, target = "value")

ff = Forecaster$new(
  learner = lrn("regr.ranger"),
  lag = 1:3
)
ff$train(task)
prediction = ff$predict(task)
# check how newdata result normally looks like
prediction = ff$predict_newdata(task, 3L)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 402.8733
#>        2    NA 450.2027
#>        3    NA 422.1766
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids    truth response
#>        1 508.0000 497.9856
#>        2 497.9856 458.0004
#>        3 458.0004 446.9533
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  24.63837

resampling = rsmp("forecast_holdout")
ff = Forecaster$new(
  learner = lrn("regr.ranger"),
  lag = 1:3
)
rr = resample(task, ff, resampling)
rr$score(msr("regr.rmse"))
#>    task_id  learner_id    resampling_id iteration regr.rmse
#> 1:      dt regr.ranger forecast_holdout         1  19.91477
#> Hidden columns: task, learner, resampling, prediction
```
