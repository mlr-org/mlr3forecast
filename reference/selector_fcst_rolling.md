# Select Forecast Rolling Features

[mlr3pipelines::Selector](https://mlr3pipelines.mlr-org.com/reference/Selector.html)
that selects rolling-window features created by
[PipeOpFcstRolling](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.rolling.md).
Matches features named `{target}_roll_{fun}_{size}` where `{target}` is
the task's target variable and `{fun}` is one of the aggregation
functions supported by
[PipeOpFcstRolling](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.rolling.md).

## Usage

``` r
selector_fcst_rolling()
```

## Value

`function`: A
[mlr3pipelines::Selector](https://mlr3pipelines.mlr-org.com/reference/Selector.html)
function.

## See also

Other Selectors:
[`selector_fcst_lags()`](https://mlr3forecast.mlr-org.com/reference/selector_fcst_lags.md)

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
pop = po("fcst.rolling", funs = c("mean", "sd"), window_sizes = c(3L, 12L))
new_task = pop$train(list(task))[[1L]]
selector_fcst_rolling()(new_task)
#> [1] "passengers_roll_mean_3"  "passengers_roll_mean_12"
#> [3] "passengers_roll_sd_3"    "passengers_roll_sd_12"  
```
