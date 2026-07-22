# Weighted Absolute Percentage Error

Measure of the total absolute error of forecasts as a percentage of the
total absolute truth. It weights each error by the magnitude of the
series, making it robust to individual observations close to zero where
the ordinary percentage error is undefined.

## Details

\$\$ \mathrm{WAPE} = 100 \cdot \frac{\sum\_{i=1}^n \lvert y_i - \hat y_i
\rvert}{\sum\_{i=1}^n \lvert y_i \rvert} \$\$

## Dictionary

This [mlr3::Measure](https://mlr3.mlr-org.com/reference/Measure.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
or with the associated sugar function
[`mlr3::msr()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_measures$get("fcst.wape")
    msr("fcst.wape")

## Task type

Forecast measures are registered with `task_type = "regr"` so they
compose with the standard regression measures (e.g.
[mlr3::mlr_measures_regr.rmse](https://mlr3.mlr-org.com/reference/mlr_measures_regr.rmse.html))
on the
[PredictionFcst](https://mlr3forecast.mlr-org.com/dev/reference/PredictionFcst.md)
that forecast learners produce. List them via the key prefix, not the
task type, as the latter returns nothing:

    as.data.table(mlr_measures)[grepl("^fcst", key)]

## Meta Information

- Task type: “regr”

- Range: \\\[0, \infty)\\

- Minimize: TRUE

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
[`mlr_measures_fcst.acf1`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.acf1.md),
[`mlr_measures_fcst.coverage`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.coverage.md),
[`mlr_measures_fcst.mase`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mase.md),
[`mlr_measures_fcst.mda`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mda.md),
[`mlr_measures_fcst.mdpv`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mdpv.md),
[`mlr_measures_fcst.mdv`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mdv.md),
[`mlr_measures_fcst.mpe`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mpe.md),
[`mlr_measures_fcst.msis`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.msis.md),
[`mlr_measures_fcst.pinball`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.pinball.md),
[`mlr_measures_fcst.rmsse`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.rmsse.md),
[`mlr_measures_fcst.winkler`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.winkler.md)

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3::MeasureRegr`](https://mlr3.mlr-org.com/reference/MeasureRegr.html)
-\> `MeasureWAPE`

## Methods

### Public methods

- [`MeasureWAPE$new()`](#method-MeasureWAPE-initialize)

- [`MeasureWAPE$clone()`](#method-MeasureWAPE-clone)

Inherited methods

- [`mlr3::Measure$aggregate()`](https://mlr3.mlr-org.com/reference/Measure.html#method-aggregate)
- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$obs_loss()`](https://mlr3.mlr-org.com/reference/Measure.html#method-obs_loss)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### `MeasureWAPE$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureWAPE$new()

------------------------------------------------------------------------

### `MeasureWAPE$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureWAPE$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
