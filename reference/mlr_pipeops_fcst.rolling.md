# Create Rolling Window Features of Target Variable

Creates rolling-window summary statistics of the target variable as new
feature columns. The window ends at position `t - lag` (exclusive of the
current and `lag - 1` most recent values) and has size `window_size`.
Use `window_size = Inf` for an expanding window that grows to include
all history up to `t - lag`.

At train time rows whose window has insufficient history are `NA` and
are dropped, matching
[PipeOpFcstLags](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.lags.md).
Predict keeps all rows.

At predict time, rolling features are computed from the task's full
backend (i.e. including rows outside `row_roles$use`), then joined onto
the active rows. Used inside
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md),
where the forecaster writes each step's prediction into the combined
task's target column between steps so rolling features for the next step
reflect the freshly predicted value.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTaskPreproc](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as the following parameters:

- `funs` :: [`character()`](https://rdrr.io/r/base/character.html)  
  Aggregation functions. Subset of
  `c("mean", "median", "sd", "min", "max", "sum")`. Default `"mean"`.

- `window_sizes` :: [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  Window sizes. Every combination of `funs` and `window_sizes` produces
  one output column. Finite sizes must be whole numbers. `Inf` requests
  an expanding window (all history up to `t - lag`). Default `3L`.

- `lag` :: `integer(1)`  
  Minimum lag before the window starts. Must be `>= 1` to avoid leakage.
  Default `1L`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFcstRolling`

## Methods

### Public methods

- [`PipeOpFcstRolling$new()`](#method-PipeOpFcstRolling-initialize)

- [`PipeOpFcstRolling$clone()`](#method-PipeOpFcstRolling-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstRolling$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstRolling$new(id = "fcst.rolling", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.rolling"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstRolling$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstRolling$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.rolling", funs = c("mean", "sd"), window_sizes = c(3L, 12L))
new_task = po$train(list(task))[[1L]]
new_task$head()
#>    passengers passengers_roll_mean_3 passengers_roll_mean_12 passengers_roll_sd_3 passengers_roll_sd_12
#>         <num>                  <num>                   <num>                <num>                 <num>
#> 1:        115               113.6667                126.6667             8.386497              13.72015
#> 2:        126               112.3333                126.9167             7.371115              13.45334
#> 3:        141               119.6667                127.5833             5.686241              13.16647
#> 4:        135               127.3333                128.3333            13.051181              13.68698
#> 5:        125               134.0000                128.8333             7.549834              13.82247
#> 6:        149               133.6667                129.1667             8.082904              13.66371
```
