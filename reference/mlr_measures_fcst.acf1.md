# Autocorrelation at Lag 1

Measures the autocorrelation of the forecast residuals at lag 1. Values
close to zero indicate that residuals are uncorrelated, while values far
from zero suggest the model is not capturing all available information.

## Details

Computed as the sample autocorrelation of the residuals at lag 1 using
[`stats::acf()`](https://rdrr.io/r/stats/acf.html).

## Dictionary

This [mlr3::Measure](https://mlr3.mlr-org.com/reference/Measure.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
or with the associated sugar function
[`mlr3::msr()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_measures$get("fcst.acf1")
    msr("fcst.acf1")

## Meta Information

- Task type: “regr”

- Range: \\\[-1, 1\]\\

- Minimize: NA

- Average: macro

- Required Prediction: “response”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast)

## Parameters

Empty ParamSet

## See also

- Chapter in the [mlr3book](https://mlr3book.mlr-org.com/):
  <https://mlr3book.mlr-org.com/chapters/chapter2/data_and_basic_modeling.html#sec-eval>

- Package
  [mlr3measures](https://CRAN.R-project.org/package=mlr3measures) for
  the scoring functions.

- [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of [Measures](https://mlr3.mlr-org.com/reference/Measure.html):
  [mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)

- `as.data.table(mlr_measures)` for a table of available
  [Measures](https://mlr3.mlr-org.com/reference/Measure.html) in the
  running session (depending on the loaded packages).

- Extension packages for additional task types:

  - [mlr3proba](https://CRAN.R-project.org/package=mlr3proba) for
    probabilistic supervised regression and survival analysis.

  - [mlr3cluster](https://CRAN.R-project.org/package=mlr3cluster) for
    unsupervised clustering.

Other Measure:
[`mlr_measures_fcst.coverage`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.coverage.md),
[`mlr_measures_fcst.mase`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mase.md),
[`mlr_measures_fcst.mda`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mda.md),
[`mlr_measures_fcst.mdpv`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mdpv.md),
[`mlr_measures_fcst.mdv`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mdv.md),
[`mlr_measures_fcst.mpe`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mpe.md),
[`mlr_measures_fcst.rmsse`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.rmsse.md),
[`mlr_measures_fcst.winkler`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.winkler.md)

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3::MeasureRegr`](https://mlr3.mlr-org.com/reference/MeasureRegr.html)
-\> `MeasureACF1`

## Methods

### Public methods

- [`MeasureACF1$new()`](#method-MeasureACF1-new)

- [`MeasureACF1$clone()`](#method-MeasureACF1-clone)

Inherited methods

- [`mlr3::Measure$aggregate()`](https://mlr3.mlr-org.com/reference/Measure.html#method-aggregate)
- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$obs_loss()`](https://mlr3.mlr-org.com/reference/Measure.html#method-obs_loss)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureACF1$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureACF1$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
