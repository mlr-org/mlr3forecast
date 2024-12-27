
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
#>        1    NA 446.8101
#>        2    NA 473.1211
#>        3    NA 485.5068
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 455.3990
#>        2   390 409.9824
#>        3   432 396.0751
prediction$score(measure)
#> regr.rmse 
#>  23.95318

ff = Forecaster$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  106.6029

resampling = rsmp("forecast_cv")
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  49.93778
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
#>        1   461 455.7255
#>        2   390 409.7808
#>        3   432 405.6454
prediction$score(measure)
#> regr.rmse 
#>  19.26714

row_ids = new_task$nrow - 0:2
ff$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 411.3026
#>        2   390 391.5954
#>        3   461 396.3538
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
ff$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 411.3026
#>        2    NA 391.5954
#>        3    NA 396.3538

resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  81.93515

resampling = rsmp("forecast_cv")
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>   42.9069
```

### mlr3pipelines integration

``` r
glrn = as_learner(pop %>>% ff)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(measure)
#> regr.rmse 
#>  18.60496
```
