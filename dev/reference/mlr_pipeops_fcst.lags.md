# Create Lags of Target Variable

Creates lagged versions of the target variable as new feature columns.

At train time the first rows of each series have no history for the
requested lags. These incomplete rows are dropped (the
autoregressive-fit convention), so the base learner never sees `NA`
lags. A keyed series shorter than the largest lag is dropped entirely,
with a warning.

At predict time lags are computed from the full series history, using
the lags stored in the state at train time.

Like every PipeOp with the `"fcst_iterative"` property, it implements
`$shift()` and `$lookback`, which move its features further into the
past and report how much history they need.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTaskPreproc](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as the following parameters:

- `lags` :: [`integer()`](https://rdrr.io/r/base/integer.html)  
  The lags to create.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFcstLags`

## Active bindings

- `lookback`:

  (`integer(1)`)  
  Number of past observations of a series the features need, i.e., the
  largest lag. Read-only.

## Methods

### Public methods

- [`PipeOpFcstLags$new()`](#method-PipeOpFcstLags-initialize)

- [`PipeOpFcstLags$shift()`](#method-PipeOpFcstLags-shift)

- [`PipeOpFcstLags$clone()`](#method-PipeOpFcstLags-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstLags$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstLags$new(id = "fcst.lags", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.lags"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstLags$shift()`

Shifts the features `k` steps further into the past by adding `k` to
every lag. Shifting by `h - 1` makes the features for horizon `h` use
only values observed at the forecast origin.

#### Usage

    PipeOpFcstLags$shift(k)

#### Arguments

- `k`:

  (`integer(1)`)  
  Number of steps to shift by.

#### Returns

`self` (invisibly).

------------------------------------------------------------------------

### `PipeOpFcstLags$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstLags$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.lags", lags = 1:3)
new_task = po$train(list(task))[[1L]]
new_task$head()
#>    passengers passengers_lag_1 passengers_lag_2 passengers_lag_3
#>         <num>            <num>            <num>            <num>
#> 1:        129              132              118              112
#> 2:        121              129              132              118
#> 3:        135              121              129              132
#> 4:        148              135              121              129
#> 5:        148              148              135              121
#> 6:        136              148              148              135
```
