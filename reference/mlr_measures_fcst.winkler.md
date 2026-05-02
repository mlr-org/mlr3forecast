# Winkler Score

Measures the quality of prediction intervals by combining their width
with a penalty for observations falling outside the interval. Smaller
scores indicate better calibrated and narrower intervals.

## Details

\$\$ W_i = \begin{cases} (u_i - l_i) + \frac{2}{\alpha}(l_i - y_i), &
\text{if } y_i \< l_i \\ (u_i - l_i), & \text{if } l_i \le y_i \le u_i
\\ (u_i - l_i) + \frac{2}{\alpha}(y_i - u_i), & \text{if } y_i \> u_i
\end{cases} \$\$ where \\l_i\\ and \\u_i\\ are the lower and upper
bounds of the prediction interval, \\y_i\\ is the observed value, and
\\\alpha = 1 - \text{level}/100\\ is the significance level. The Winkler
score is then the mean of \\W_i\\ over all observations.

## Dictionary

This [mlr3::Measure](https://mlr3.mlr-org.com/reference/Measure.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_measures](https://mlr3.mlr-org.com/reference/mlr_measures.html)
or with the associated sugar function
[`mlr3::msr()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_measures$get("fcst.winkler")
    msr("fcst.winkler")

## Meta Information

- Task type: “regr”

- Range: \\\[0, \infty)\\

- Minimize: TRUE

- Average: macro

- Required Prediction: “quantiles”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast)

## Parameters

|       |         |         |              |
|-------|---------|---------|--------------|
| Id    | Type    | Default | Range        |
| alpha | numeric | \-      | \\\[0, 1\]\\ |

## References

Winkler, L R (1972). “A Decision-Theoretic Approach to Interval
Estimation.” *Journal of the American Statistical Association*,
**67**(337), 187–191.

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
[`mlr_measures_fcst.rmsse`](https://mlr3forecast.mlr-org.com/reference/mlr_measures_fcst.rmsse.md)

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3::MeasureRegr`](https://mlr3.mlr-org.com/reference/MeasureRegr.html)
-\> `MeasureWinkler`

## Methods

### Public methods

- [`MeasureWinkler$new()`](#method-MeasureWinkler-initialize)

- [`MeasureWinkler$clone()`](#method-MeasureWinkler-clone)

Inherited methods

- [`mlr3::Measure$aggregate()`](https://mlr3.mlr-org.com/reference/Measure.html#method-aggregate)
- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$obs_loss()`](https://mlr3.mlr-org.com/reference/Measure.html#method-obs_loss)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### `MeasureWinkler$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureWinkler$new()

------------------------------------------------------------------------

### `MeasureWinkler$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureWinkler$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
