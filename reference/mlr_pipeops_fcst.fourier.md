# Create Fourier Features for Seasonality

Creates pairs of Fourier (harmonic) terms `sin(2 * pi * k * t / period)`
and `cos(2 * pi * k * t / period)` as new feature columns, for
`k = 1, ..., K` harmonics per seasonal `period`, where `t` is the
per-series time position. They encode seasonality as a flexible
alternative to seasonal lags, in particular for long or non-integer
periods and multiple seasonalities at once.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTaskPreprocSimple](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html),
as well as the following parameters:

- `period` :: [`numeric()`](https://rdrr.io/r/base/numeric.html) \|
  `NULL`  
  Seasonal period(s), in number of observations per cycle. May be
  non-integer and may contain multiple periods for multiple
  seasonalities. If `NULL` (default), the period is derived from the
  task's frequency (`task$freq`).

- `K` :: [`integer()`](https://rdrr.io/r/base/integer.html)  
  Number of Fourier harmonics per `period`. Either a single value
  recycled to all periods, or one value per period. Each `K` must
  satisfy `2 * K <= period`. Default `1L`.

## References

De Livera, A.M., Hyndman, R.J., Snyder, R.D. (2011). “Forecasting time
series with complex seasonal patterns using exponential smoothing.”
*Journal of the American Statistical Association*, **106**(496),
1513–1527.

Hyndman, J. R, Khandakar, Yeasmin (2008). “Automatic Time Series
Forecasting: The forecast Package for R.” *Journal of Statistical
Software*, **27**(3), 1–22.
[doi:10.18637/jss.v027.i03](https://doi.org/10.18637/jss.v027.i03) .
<https://www.jstatsoft.org/index.php/jss/article/view/v027i03>.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\>
[`mlr3pipelines::PipeOpTaskPreprocSimple`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreprocSimple.html)
-\> `PipeOpFcstFourier`

## Methods

### Public methods

- [`PipeOpFcstFourier$new()`](#method-PipeOpFcstFourier-initialize)

- [`PipeOpFcstFourier$clone()`](#method-PipeOpFcstFourier-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstFourier$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstFourier$new(id = "fcst.fourier", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.fourier"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstFourier$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstFourier$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.fourier", period = 12, K = 3L)
new_task = po$train(list(task))[[1L]]
new_task$head()
#>    passengers     S1_12      C1_12      S2_12 C2_12 S3_12 C3_12
#>         <num>     <num>      <num>      <num> <num> <num> <num>
#> 1:        112 0.5000000  0.8660254  0.8660254   0.5     1     0
#> 2:        118 0.8660254  0.5000000  0.8660254  -0.5     0    -1
#> 3:        132 1.0000000  0.0000000  0.0000000  -1.0    -1     0
#> 4:        129 0.8660254 -0.5000000 -0.8660254  -0.5     0     1
#> 5:        121 0.5000000 -0.8660254 -0.8660254   0.5     1     0
#> 6:        135 0.0000000 -1.0000000  0.0000000   1.0     0    -1
```
