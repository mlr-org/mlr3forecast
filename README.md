
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
task$select(setdiff(task$feature_names, "date"))
measure = msr("regr.rmse")
ff = Forecaster$new(task, lrn("regr.ranger"), 1:3)$train(task)
newdata = data.frame(passengers = rep(NA_real_, 3L))
prediction = ff$predict_newdata(newdata, task)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 450.0966
#>        2    NA 474.7014
#>        3    NA 485.3662
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 460.4653
#>        2   390 407.4401
#>        3   432 396.2179
prediction$score(measure)
#> regr.rmse 
#>  22.98407

resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, ff, resampling)
rr$score(measure)
#>          task_id  learner_id    resampling_id iteration regr.rmse
#> 1: airpassengers regr.ranger forecast_holdout         1  107.2289
#> Hidden columns: task, learner, resampling, prediction_test

resampling = rsmp("forecast_cv")
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  51.20677
```

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsk("airpassengers")
pop = po("datefeatures",
  param_vals = list(is_day = FALSE, cyclic = FALSE, hour = FALSE, minute = FALSE, second = FALSE)
)
new_task = pop$train(list(task))[[1L]]
ff = Forecaster$new(new_task, lrn("regr.ranger"), 1:3)$train(new_task)
prediction = ff$predict(new_task, 142:144)
ff$predict(new_task, 142:144)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 453.3343
#>        2   390 406.8129
#>        3   432 404.1475
prediction$score(measure)
#> regr.rmse 
#>  19.29766

row_ids = new_task$nrow - 0:2
ff$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 412.8199
#>        2   390 392.8973
#>        3   461 397.1740
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
ff$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 412.8199
#>        2    NA 392.8973
#>        3    NA 397.1740
```

``` r
# doesn't work since the graph learner does its own thing
glrn = as_learner(pop %>>% ff)$train(task)
glrn$predict(task, 142:144)
```
