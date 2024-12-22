
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

dt = tsbox::ts_dt(AirPassengers)
dt[, time := NULL]
task = as_task_regr(dt, target = "value")

ff = Forecaster$new(
  learner = lrn("regr.ranger"),
  lag = 1:3
)
ff$train(task)
prediction = ff$predict(task)
prediction
#> <PredictionRegr> for 144 observations:
#>  row_ids truth response
#>        1   112 283.4395
#>        2   118 283.4395
#>        3   132 283.4395
#>      ---   ---      ---
#>      142   461 283.4395
#>      143   390 283.4395
#>      144   432 283.4395
prediction = ff$predict_newdata(task, 3L)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 283.4395
#>        2    NA 283.4395
#>        3    NA 283.4395
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 283.4395
#>        2   390 283.4395
#>        3   432 283.4395
prediction$score(msr("regr.rmse"))
#> regr.rmse 
#>  147.1429
```
