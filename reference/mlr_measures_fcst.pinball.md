# Pinball Loss

Measures the quality of quantile (probabilistic) forecasts using the
pinball loss, also known as the quantile loss. The loss is averaged over
all observations and all predicted quantile levels. Smaller scores
indicate better calibrated quantile forecasts.

## Details

For a single quantile level \\\tau\\ with forecast \\q_i\\ and
observation \\y_i\\ the pinball loss is \$\$ L\_\tau(y_i, q_i) =
\begin{cases} \tau\\(y_i - q_i), & \text{if } y_i \ge q_i \\ (1 -
\tau)\\(q_i - y_i), & \text{if } y_i \< q_i \end{cases} \$\$ The
reported score is twice the mean of \\L\_\tau\\ over all observations
and all quantile levels \\\tau\\, matching the convention used by
[fabletools](https://CRAN.R-project.org/package=fabletools) so that the
median (\\\tau = 0.5\\) pinball loss equals the mean absolute error.

## Dictionary

This [mlr3::Measure](https://mlr3.mlr-org.com/reference/Measure.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
or with the associated sugar function
[`mlr3::msr()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_measures$get("fcst.pinball")
    msr("fcst.pinball")

## Task type

Forecast measures are registered with `task_type = "regr"` so they
compose with the standard regression measures (e.g.
[mlr3::mlr_measures_regr.rmse](https://mlr3.mlr-org.com/reference/mlr_measures_regr.rmse.html))
on the
[mlr3::PredictionRegr](https://mlr3.mlr-org.com/reference/PredictionRegr.html)
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

Empty ParamSet

## References

Koenker R, Bassett G (1978). “Regression Quantiles.” *Econometrica*,
**46**(1), 33–50.

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
[`mlr_measures_fcst.msis`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.msis.md),
[`mlr_measures_fcst.rmsse`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.rmsse.md),
[`mlr_measures_fcst.wape`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.wape.md),
[`mlr_measures_fcst.winkler`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.winkler.md)

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3::MeasureRegr`](https://mlr3.mlr-org.com/reference/MeasureRegr.html)
-\> `MeasurePinball`

## Methods

### Public methods

- [`MeasurePinball$new()`](#method-MeasurePinball-initialize)

- [`MeasurePinball$clone()`](#method-MeasurePinball-clone)

Inherited methods

- [`mlr3::Measure$aggregate()`](https://mlr3.mlr-org.com/reference/Measure.html#method-aggregate)
- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$obs_loss()`](https://mlr3.mlr-org.com/reference/Measure.html#method-obs_loss)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### `MeasurePinball$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasurePinball$new()

------------------------------------------------------------------------

### `MeasurePinball$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasurePinball$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
