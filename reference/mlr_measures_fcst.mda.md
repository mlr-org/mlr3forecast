# Mean Directional Accuracy

Measure of the proportion of correctly predicted directions between
successive observations in forecast tasks.

## Details

\$\$ \mathrm{MDA} = (a - b)\\\frac{1}{n-1} \sum\_{i=2}^n
\mathbf{1}\\\mathrm{sign}(y_i - y\_{i-1}) = \mathrm{sign}(\hat y_i -
\hat y\_{i-1})\\ \\+\\ p \$\$ where `a` is the reward for a correct
direction (default `1`), `b` is the penalty for an incorrect direction
(default `0`), and `n` is the number of observations.

## Dictionary

This [mlr3::Measure](https://mlr3.mlr-org.com/reference/Measure.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
or with the associated sugar function
[`mlr3::msr()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_measures$get("fcst.mda")
    msr("fcst.mda")

## Meta Information

- Task type: “regr”

- Range: \\(-\infty, \infty)\\

- Minimize: FALSE

- Average: macro

- Required Prediction: “response”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast)

## Parameters

|         |         |         |                       |
|---------|---------|---------|-----------------------|
| Id      | Type    | Default | Range                 |
| reward  | numeric | \-      | \\(-\infty, \infty)\\ |
| penalty | numeric | \-      | \\(-\infty, \infty)\\ |

## References

Blaskowitz, Herwartz H (2011). “On economic evaluation of directional
forecasts.” *International Journal of Forecasting*, **27**(4),
1058–1065.

## See also

- Chapter in the [mlr3book](https://mlr3book.mlr-org.com/):
  <https://mlr3book.mlr-org.com/chapters/chapter2/data_and_basic_modeling.html#sec-eval>

- Package
  [mlr3measures](https://CRAN.R-project.org/package=mlr3measures) for
  the scoring functions.
  [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of [Measures](https://mlr3.mlr-org.com/reference/Measure.html):
  [mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
  `as.data.table(mlr_measures)` for a table of available
  [Measures](https://mlr3.mlr-org.com/reference/Measure.html) in the
  running session (depending on the loaded packages).

- Extension packages for additional task types:

  - [mlr3proba](https://CRAN.R-project.org/package=mlr3proba) for
    probabilistic supervised regression and survival analysis.

  - [mlr3cluster](https://CRAN.R-project.org/package=mlr3cluster) for
    unsupervised clustering.

Other Measure:
[`mlr_measures_fcst.mdpv`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mdpv.md),
[`mlr_measures_fcst.mdv`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.mdv.md)

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3::MeasureRegr`](https://mlr3.mlr-org.com/reference/MeasureRegr.html)
-\> `MeasureMDA`

## Methods

### Public methods

- [`MeasureMDA$new()`](#method-MeasureMDA-new)

- [`MeasureMDA$clone()`](#method-MeasureMDA-clone)

Inherited methods

- [`mlr3::Measure$aggregate()`](https://mlr3.mlr-org.com/reference/Measure.html#method-aggregate)
- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureMDA$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureMDA$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
