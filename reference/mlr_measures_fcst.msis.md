# Mean Scaled Interval Score

Measures the quality of central prediction intervals, scaling the
interval (Winkler) score by the in-sample mean absolute error of the
naive (or seasonal naive) forecast. The interval score rewards narrow
intervals and penalizes observations falling outside them, and the
scaling makes the measure comparable across series of different
magnitudes. This is the prediction-interval metric used in the M4
competition. Smaller scores indicate better calibrated and narrower
intervals.

## Details

For a central interval at level `1 - alpha` with lower and upper bounds
\\l_i\\ and \\u_i\\ (the `alpha/2` and `1 - alpha/2` quantiles): \$\$
\mathrm{MSIS} = \frac{\frac{1}{n} \sum\_{i=1}^n (u_i - l_i) +
\frac{2}{\alpha}(l_i - y_i)\mathbf{1}\\y_i \< l_i\\ +
\frac{2}{\alpha}(y_i - u_i)\mathbf{1}\\y_i \> u_i\\} {\frac{1}{T-m}
\sum\_{t=m+1}^T \lvert z_t - z\_{t-m} \rvert} \$\$ where \\z\\ is the
training series, \\m\\ is the seasonal period, and \\T\\ is the length
of the training series. For keyed tasks the score is computed per series
and averaged.

## Dictionary

This [mlr3::Measure](https://mlr3.mlr-org.com/reference/Measure.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
or with the associated sugar function
[`mlr3::msr()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_measures$get("fcst.msis")
    msr("fcst.msis")

## Task type

Forecast measures are registered with `task_type = "regr"` so they
compose with the standard regression measures (e.g.
[mlr3::mlr_measures_regr.rmse](https://mlr3.mlr-org.com/reference/mlr_measures_regr.rmse.html))
on the
[PredictionFcst](https://mlr3forecast.mlr-org.com/reference/PredictionFcst.md)
that forecast learners produce. List them via the key prefix, not the
task type, as the latter returns nothing:

    as.data.table(mlr_measures)[grepl("^fcst", key)]

## Meta Information

- Task type: “regr”

- Range: \\\[0, \infty)\\

- Minimize: TRUE

- Average: macro

- Required Prediction: “quantiles”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast)

## Parameters

|        |         |         |                  |
|--------|---------|---------|------------------|
| Id     | Type    | Default | Range            |
| alpha  | numeric | \-      | \\\[0, 1\]\\     |
| period | integer | \-      | \\\[1, \infty)\\ |

## References

Gneiting T, Raftery AE (2007). “Strictly Proper Scoring Rules,
Prediction, and Estimation.” *Journal of the American Statistical
Association*, **102**(477), 359–378.

Makridakis S, Spiliotis E, Assimakopoulos V (2020). “The M4 Competition:
100,000 time series and 61 forecasting methods.” *International Journal
of Forecasting*, **36**(1), 54–74.

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
[`mlr_measures_fcst.acf1`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.acf1.md),
[`mlr_measures_fcst.coverage`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.coverage.md),
[`mlr_measures_fcst.mase`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mase.md),
[`mlr_measures_fcst.mda`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mda.md),
[`mlr_measures_fcst.mdpv`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mdpv.md),
[`mlr_measures_fcst.mdv`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mdv.md),
[`mlr_measures_fcst.mpe`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mpe.md),
[`mlr_measures_fcst.pinball`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.pinball.md),
[`mlr_measures_fcst.rmsse`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.rmsse.md),
[`mlr_measures_fcst.wape`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.wape.md),
[`mlr_measures_fcst.winkler`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.winkler.md)

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3::MeasureRegr`](https://mlr3.mlr-org.com/reference/MeasureRegr.html)
-\> `MeasureMSIS`

## Methods

### Public methods

- [`MeasureMSIS$new()`](#method-MeasureMSIS-initialize)

- [`MeasureMSIS$clone()`](#method-MeasureMSIS-clone)

Inherited methods

- [`mlr3::Measure$aggregate()`](https://mlr3.mlr-org.com/reference/Measure.html#method-aggregate)
- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$obs_loss()`](https://mlr3.mlr-org.com/reference/Measure.html#method-obs_loss)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### `MeasureMSIS$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureMSIS$new()

------------------------------------------------------------------------

### `MeasureMSIS$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureMSIS$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
