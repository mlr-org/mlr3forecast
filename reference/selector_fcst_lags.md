# Select Forecast Lag Features

[mlr3pipelines::Selector](https://mlr3pipelines.mlr-org.com/reference/Selector.html)
that selects lag features created by
[PipeOpFcstLags](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.lags.md).
Matches features named `{target}_lag_{i}` where `{target}` is the task's
target variable.

## Usage

``` r
selector_fcst_lags()
```

## Value

`function`: A
[mlr3pipelines::Selector](https://mlr3pipelines.mlr-org.com/reference/Selector.html)
function.

## See also

Other Selectors:
[`selector_fcst_rolling()`](https://mlr3forecast.mlr-org.com/reference/selector_fcst_rolling.md)

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
pop = po("fcst.lags", lags = 1:3)
new_task = pop$train(list(task))[[1L]]
selector_fcst_lags()(new_task)
#> [1] "passengers_lag_1" "passengers_lag_2" "passengers_lag_3"
```
