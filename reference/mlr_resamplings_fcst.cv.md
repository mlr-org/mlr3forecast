# Forecast Cross-Validation Resampling

Splits data using a `folds`-folds (default: 10 folds) rolling window
cross-validation.

## Dictionary

This [Resampling](https://mlr3.mlr-org.com/reference/Resampling.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_resamplings](https://mlr3.mlr-org.com/reference/mlr_resamplings.html)
or with the associated sugar function
[rsmp()](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_resamplings$get("fcst.cv")
    rsmp("fcst.cv")

## Parameters

- `horizon` (`integer(1)`)  
  Forecasting horizon in the test sets, i.e. number of test samples for
  each fold.

- `folds` (`integer(1)`)  
  Number of folds.

- `step_size` (`integer(1)`)  
  Step size between windows.

- `window_size` (`integer(1)`)  
  (Minimal) Size of the rolling window.

- `fixed_window` (`logial(1)`)  
  Should a fixed sized window be used? If `FALSE` an expanding window is
  used.

## References

Bergmeir, Christoph, Hyndman, J R, Koo, Bonsoo (2018). “A note on the
validity of cross-validation for evaluating autoregressive time series
prediction.” *Computational Statistics & Data Analysis*, **120**, 70–83.

## See also

- Chapter in the [mlr3book](https://mlr3book.mlr-org.com/):
  <https://mlr3book.mlr-org.com/chapters/chapter3/evaluation_and_benchmarking.html#sec-resampling>

- Package
  [mlr3spatiotempcv](https://CRAN.R-project.org/package=mlr3spatiotempcv)
  for spatio-temporal resamplings.

- [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of [Resamplings](https://mlr3.mlr-org.com/reference/Resampling.html):
  [mlr3::mlr_resamplings](https://mlr3.mlr-org.com/reference/mlr_resamplings.html)

- `as.data.table(mlr_resamplings)` for a table of available
  [Resamplings](https://mlr3.mlr-org.com/reference/Resampling.html) in
  the running session (depending on the loaded packages).

- [mlr3spatiotempcv](https://CRAN.R-project.org/package=mlr3spatiotempcv)
  for additional
  [mlr3::Resampling](https://mlr3.mlr-org.com/reference/Resampling.html)s
  for spatio-temporal tasks.

Other Resampling:
[`mlr_resamplings_fcst.holdout`](https://mlr3forecast.mlr-org.com/reference/mlr_resamplings_fcst.holdout.md)

## Super class

[`mlr3::Resampling`](https://mlr3.mlr-org.com/reference/Resampling.html)
-\> `ResamplingFcstCV`

## Active bindings

- `iters`:

  (`integer(1)`)  
  Returns the number of resampling iterations, depending on the values
  stored in the `param_set`.

## Methods

### Public methods

- [`ResamplingFcstCV$new()`](#method-ResamplingFcstCV-new)

- [`ResamplingFcstCV$clone()`](#method-ResamplingFcstCV-clone)

Inherited methods

- [`mlr3::Resampling$format()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-format)
- [`mlr3::Resampling$help()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-help)
- [`mlr3::Resampling$instantiate()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-instantiate)
- [`mlr3::Resampling$print()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-print)
- [`mlr3::Resampling$test_set()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-test_set)
- [`mlr3::Resampling$train_set()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-train_set)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ResamplingFcstCV$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ResamplingFcstCV$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Create a task with 10 observations
task = tsk("airpassengers")
task$filter(1:20)

# Instantiate Resampling
cv = rsmp("fcst.cv", folds = 3, fixed_window = FALSE)
cv$instantiate(task)
#> Error in is.finite(if (is.character(from)) from <- as.numeric(from) else from): default method not implemented for type 'list'

# Individual sets:
cv$train_set(1)
#> Error: Resampling 'fcst.cv' has not been instantiated yet
cv$test_set(1)
#> Error: Resampling 'fcst.cv' has not been instantiated yet
intersect(cv$train_set(1), cv$test_set(1))
#> Error: Resampling 'fcst.cv' has not been instantiated yet

# Internal storage:
cv$instance #  list
#> NULL
```
