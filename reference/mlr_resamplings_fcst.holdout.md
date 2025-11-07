# Forecast Holdout Resampling

Splits data into a training set and a test set. Parameter `ratio`
determines the ratio of observation going into the training set
(default: 2/3).

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

- `ratio` (`numeric(1)`)  
  Ratio of observations to put into the training set. Mutually exclusive
  with parameter `n`.

- `n` (`integer(1)`)  
  Number of observations to put into the training set. If negative, the
  absolute value determines the number of observations in the test set.
  Mutually exclusive with parameter `ratio`.

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
[`mlr_resamplings_fcst.cv`](https://mlr3forecast.mlr-org.com/reference/mlr_resamplings_fcst.cv.md)

## Super class

[`mlr3::Resampling`](https://mlr3.mlr-org.com/reference/Resampling.html)
-\> `ResamplingFcstHoldout`

## Active bindings

- `iters`:

  (`integer(1)`)  
  Returns the number of resampling iterations, depending on the values
  stored in the `param_set`.

## Methods

### Public methods

- [`ResamplingFcstHoldout$new()`](#method-ResamplingFcstHoldout-new)

- [`ResamplingFcstHoldout$clone()`](#method-ResamplingFcstHoldout-clone)

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

    ResamplingFcstHoldout$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ResamplingFcstHoldout$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Create a task with 10 observations
task = tsk("airpassengers")
task$filter(1:10)

# Instantiate Resampling
holdout = rsmp("fcst.holdout", ratio = 0.5)
holdout$instantiate(task)

# Individual sets:
holdout$train_set(1)
#> [1] 1 2 3 4 5
holdout$test_set(1)
#> [1]  6  7  8  9 10

# Disjunct sets:
intersect(holdout$train_set(1), holdout$test_set(1))
#> integer(0)

# Internal storage:
holdout$instance # simple list
#> $train
#> [1] 1 2 3 4 5
#> 
#> $test
#> [1]  6  7  8  9 10
#> 
```
