
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
#>        1    NA 450.0689
#>        2    NA 472.9712
#>        3    NA 482.1500
prediction = ff$predict(task, 142:144)
#> Warning in warn_deprecated("Task$data_formats"): Task$data_formats is
#> deprecated and will be removed in the future.
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 455.8978
#>        2   390 414.0475
#>        3   432 402.1915
prediction$score(measure)
#> regr.rmse 
#>   22.3074

ff = Forecaster$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  105.1936

resampling = rsmp("forecast_cv")
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  54.36987
```

### Multivariate

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsk("airpassengers")
pop = po("datefeatures",
  param_vals = list(is_day = FALSE, cyclic = FALSE, hour = FALSE, minute = FALSE, second = FALSE)
)
new_task = pop$train(list(task))[[1L]]
ff = Forecaster$new(lrn("regr.ranger"), 1:3)$train(new_task)
prediction = ff$predict(new_task, 142:144)
ff$predict(new_task, 142:144)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 456.5591
#>        2   390 410.6596
#>        3   432 408.2172
prediction$score(measure)
#> regr.rmse 
#>  18.36813

row_ids = new_task$nrow - 0:2
ff$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 412.9277
#>        2   390 391.1173
#>        3   461 398.0259
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
ff$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 412.9277
#>        2    NA 391.1173
#>        3    NA 398.0259

resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>   81.0461

resampling = rsmp("forecast_cv")
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  44.99413
```

### WIP

``` r
# doesn't work since the graph learner does its own thing
glrn = as_learner(pop %>>% ff)$train(task)
glrn$predict(task, 142:144)
```
