
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
library(mlr3learners)

task = tsk("airpassengers")
ff = Forecaster$new(
  learner = lrn("regr.ranger"),
  lag = 1:3
)
ff$train(task)
prediction = ff$predict(task)
prediction
#> <PredictionRegr> for 144 observations:
#>  row_ids truth response
#>        1   112 283.8407
#>        2   118 283.8407
#>        3   132 283.8407
#>      ---   ---      ---
#>      142   461 283.8407
#>      143   390 283.8407
#>      144   432 283.8407
prediction = ff$predict_newdata(task, 3L)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 283.8407
#>        2    NA 283.8407
#>        3    NA 283.8407
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 283.8407
#>        2   390 283.8407
#>        3   432 283.8407
measure = msr("regr.rmse")
prediction$score(measure)
#> regr.rmse 
#>  146.7496

resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, ff, resampling)
rr$score(measure)
#>          task_id  learner_id    resampling_id iteration regr.rmse
#> 1: airpassengers regr.ranger forecast_holdout         1  212.0479
#> Hidden columns: task, learner, resampling, prediction_test

resampling = rsmp("forecast_cv")
rr = resample(task, ff, resampling)
rr$score(measure)
#>          task_id  learner_id resampling_id iteration regr.rmse
#> 1: airpassengers regr.ranger   forecast_cv         1  150.0980
#> 2: airpassengers regr.ranger   forecast_cv         2  107.5167
#> 3: airpassengers regr.ranger   forecast_cv         3  180.1955
#> 4: airpassengers regr.ranger   forecast_cv         4  229.2605
#> 5: airpassengers regr.ranger   forecast_cv         5  329.6771
#> Hidden columns: task, learner, resampling, prediction_test
```
