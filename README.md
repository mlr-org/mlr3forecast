
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
#>        1    NA 445.6966
#>        2    NA 474.1113
#>        3    NA 483.3287
prediction = ff$predict(task, 142:144)
prediction
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   461 458.3815
#>        2   390 410.9329
#>        3   432 395.2375
prediction$score(measure)
#> regr.rmse 
#>  24.47126

ff = Forecaster$new(lrn("regr.ranger"), 1:3)
resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  111.1243

resampling = rsmp("forecast_cv")
rr = resample(task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  53.55455
```

### Multivariate

``` r
library(mlr3learners)
library(mlr3pipelines)

task = tsk("airpassengers")
# datefeatures currently requires POSIXct
graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(is_day = FALSE, cyclic = FALSE, hour = FALSE, minute = FALSE, second = FALSE)
  )
new_task = graph$train(task)[[1L]]
ff = Forecaster$new(lrn("regr.ranger"), 1:3)$train(new_task)
prediction = ff$predict(new_task, 142:144)
prediction$score(measure)
#> regr.rmse 
#>  19.19258

row_ids = new_task$nrow - 0:2
ff$predict_newdata(new_task$data(rows = row_ids), new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1   432 406.4261
#>        2   390 390.4117
#>        3   461 395.0697
newdata = new_task$data(rows = row_ids, cols = new_task$feature_names)
ff$predict_newdata(newdata, new_task)
#> <PredictionRegr> for 3 observations:
#>  row_ids truth response
#>        1    NA 406.4261
#>        2    NA 390.4117
#>        3    NA 395.0697

resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  79.89178

resampling = rsmp("forecast_cv")
rr = resample(new_task, ff, resampling)
rr$aggregate(measure)
#> regr.rmse 
#>  45.18738
```

### mlr3pipelines integration

``` r
ff = Forecaster$new(lrn("regr.ranger"), 1:3)
glrn = as_learner(graph %>>% ff)$train(task)
prediction = glrn$predict(task, 142:144)
prediction$score(measure)
#> regr.rmse 
#>  34.23849
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
  as_task_regr(target = "demand")

graph = ppl("convert_types", "Date", "POSIXct") %>>%
  po("datefeatures",
    param_vals = list(is_day = FALSE, cyclic = FALSE, hour = FALSE, minute = FALSE, second = FALSE)
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
#>        1    NA 187.1200
#>        2    NA 191.2271
#>        3    NA 184.5125
#>      ---   ---      ---
#>       12    NA 214.8611
#>       13    NA 217.7954
#>       14    NA 219.8105
```
