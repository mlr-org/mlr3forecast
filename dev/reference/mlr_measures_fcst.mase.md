# Mean Absolute Scaled Error

Measures the mean absolute error of the forecast scaled by the in-sample
mean absolute error of the naive (or seasonal naive) forecast. Values
less than one indicate the forecast is better than the naive baseline.

## Details

\$\$ \mathrm{MASE} = \frac{1}{n} \sum\_{i=1}^n \frac{\lvert y_i - \hat
y_i \rvert} {\frac{1}{T-m} \sum\_{t=m+1}^T \lvert z_t - z\_{t-m} \rvert}
\$\$ where \\z\\ is the training series, \\m\\ is the seasonal period,
and \\T\\ is the length of the training series. `period` is the seasonal
lag of the naive benchmark, rounded to the nearest positive integer.

## Seasonal period

The seasonal period is not stored in the task. It is set by the `period`
hyperparameter, in observations per cycle. Either a positive number such
as `12`, or a cycle name resolved against the task's `freq` such as
`"year"` or `"week"`. The cycle names a calendar `freq` implies and the
periods they resolve to are:

|             |          |         |          |          |
|-------------|----------|---------|----------|----------|
| `freq`      | `"hour"` | `"day"` | `"week"` | `"year"` |
| `"min"`     | 60       | 1440    | 10080    | 525960   |
| `"hour"`    |          | 24      | 168      | 8766     |
| `"day"`     |          |         | 7        | 365.25   |
| `"week"`    |          |         |          | 52.18    |
| `"month"`   |          |         |          | 12       |
| `"quarter"` |          |         |          | 4        |

A multiple of a unit divides the period, e.g. `"30 min"` resolves
`"day"` to `48`. If `period` is `NULL` (default), it is the day for
sub-daily data (the hour below a minute), the week for daily data, and
the year for longer steps, skipping a cycle of fewer than four
observations for the next longer one. This gives e.g. `12` for monthly,
`4` for quarterly, `7` for daily, `24` for hourly, and `48` for
half-hourly data. Without a calendar `freq`, the default is `1`, i.e. no
seasonality.

## Dictionary

This [mlr3::Measure](https://mlr3.mlr-org.com/reference/Measure.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
or with the associated sugar function
[`mlr3::msr()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_measures$get("fcst.mase")
    msr("fcst.mase")

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

|        |         |         |
|--------|---------|---------|
| Id     | Type    | Default |
| period | untyped | NULL    |

## References

Hyndman RJ, Koehler AB (2006). “Another look at measures of forecast
accuracy.” *International Journal of Forecasting*, **22**(4), 679–688.

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
[`mlr_measures_fcst.mda`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mda.md),
[`mlr_measures_fcst.mdpv`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mdpv.md),
[`mlr_measures_fcst.mdv`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mdv.md),
[`mlr_measures_fcst.mpe`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.mpe.md),
[`mlr_measures_fcst.msis`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.msis.md),
[`mlr_measures_fcst.pinball`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.pinball.md),
[`mlr_measures_fcst.rmsse`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.rmsse.md),
[`mlr_measures_fcst.wape`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.wape.md),
[`mlr_measures_fcst.winkler`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_measures_fcst.winkler.md)

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3::MeasureRegr`](https://mlr3.mlr-org.com/reference/MeasureRegr.html)
-\> `MeasureMASE`

## Methods

### Public methods

- [`MeasureMASE$new()`](#method-MeasureMASE-initialize)

- [`MeasureMASE$clone()`](#method-MeasureMASE-clone)

Inherited methods

- [`mlr3::Measure$aggregate()`](https://mlr3.mlr-org.com/reference/Measure.html#method-aggregate)
- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$obs_loss()`](https://mlr3.mlr-org.com/reference/Measure.html#method-obs_loss)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### `MeasureMASE$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureMASE$new()

------------------------------------------------------------------------

### `MeasureMASE$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureMASE$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
