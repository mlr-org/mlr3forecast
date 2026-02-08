# Create Lags of Target Variable

Creates lagged versions of the target variable as new feature columns.

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

## Methods

### Public methods

- [`PipeOpFcstLags$new()`](#method-PipeOpFcstLags-new)

- [`PipeOpFcstLags$clone()`](#method-PipeOpFcstLags-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### Method `new()`

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

### Method `clone()`

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
#>    passengers      month passengers_lag_1 passengers_lag_2 passengers_lag_3
#>         <num>     <Date>            <num>            <num>            <num>
#> 1:        112 1949-01-01               NA               NA               NA
#> 2:        118 1949-02-01              112               NA               NA
#> 3:        132 1949-03-01              118              112               NA
#> 4:        129 1949-04-01              132              118              112
#> 5:        121 1949-05-01              129              132              118
#> 6:        135 1949-06-01              121              129              132
```
