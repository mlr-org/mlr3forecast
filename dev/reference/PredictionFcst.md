# Prediction Object for Forecasting

This object wraps the predictions returned by a forecast learner
([LearnerFcst](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcst.md),
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md),
[DirectForecaster](https://mlr3forecast.mlr-org.com/dev/reference/DirectForecaster.md)).
It subclasses
[mlr3::PredictionRegr](https://mlr3.mlr-org.com/reference/PredictionRegr.html),
so forecasting is treated as regression: the `response`, `se`,
`quantiles` and `distr` fields and all regression measures continue to
work.

In addition, the prediction carries the time index (and any key columns)
of the forecast horizon in its `$data$extra` slot. These are exposed via
the `$order` and `$key` fields, lead the
[`as.data.table()`](https://rdrr.io/pkg/data.table/man/as.data.table.html)
output, and are used by
[`autoplot.PredictionFcst()`](https://mlr3forecast.mlr-org.com/dev/reference/autoplot.PredictionFcst.md)
to draw a forecast plot.

The `task_type` is kept as `"regr"` so that regression measures remain
compatible: forecasting is scored as regression.

## See also

Package [mlr3viz](https://CRAN.R-project.org/package=mlr3viz) for some
generic visualizations.

## Super classes

[`mlr3::Prediction`](https://mlr3.mlr-org.com/reference/Prediction.html)
-\>
[`mlr3::PredictionRegr`](https://mlr3.mlr-org.com/reference/PredictionRegr.html)
-\> `PredictionFcst`

## Active bindings

- `order`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
  \| `NULL`)  
  The forecast time index, recovered from `$data$extra`. A table with
  two columns:

  - `row_id` ([`integer()`](https://rdrr.io/r/base/integer.html)), and

  - `order` (`Date()` \| `POSIXct()` \|
    [`integer()`](https://rdrr.io/r/base/integer.html) \|
    [`numeric()`](https://rdrr.io/r/base/numeric.html)).

  Returns `NULL` if no extra data is stored.

- `key`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
  \| `NULL`)  
  The series identity columns of the forecast horizon, recovered from
  `$data$extra`. A table with two or more columns:

  - `row_id` ([`integer()`](https://rdrr.io/r/base/integer.html)), and

  - key variable(s) ([`factor()`](https://rdrr.io/r/base/factor.html) \|
    [`ordered()`](https://rdrr.io/r/base/factor.html)).

  If there is only one key column, it is named `key`. Returns `NULL` if
  there are no key columns.

## Methods

### Public methods

- [`PredictionFcst$new()`](#method-PredictionFcst-initialize)

- [`PredictionFcst$clone()`](#method-PredictionFcst-clone)

Inherited methods

- [`mlr3::Prediction$filter()`](https://mlr3.mlr-org.com/reference/Prediction.html#method-filter)
- [`mlr3::Prediction$format()`](https://mlr3.mlr-org.com/reference/Prediction.html#method-format)
- [`mlr3::Prediction$help()`](https://mlr3.mlr-org.com/reference/Prediction.html#method-help)
- [`mlr3::Prediction$obs_loss()`](https://mlr3.mlr-org.com/reference/Prediction.html#method-obs_loss)
- [`mlr3::Prediction$print()`](https://mlr3.mlr-org.com/reference/Prediction.html#method-print)
- [`mlr3::Prediction$score()`](https://mlr3.mlr-org.com/reference/Prediction.html#method-score)

------------------------------------------------------------------------

### `PredictionFcst$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    PredictionFcst$new(
      task = NULL,
      row_ids = task$row_ids,
      truth = task$truth(),
      response = NULL,
      se = NULL,
      quantiles = NULL,
      distr = NULL,
      weights = NULL,
      check = TRUE,
      extra = NULL,
      raw = NULL
    )

#### Arguments

- `task`:

  ([TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md))  
  Task, used to extract defaults for `row_ids` and `truth`.

- `row_ids`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  Row ids of the predicted observations, i.e. the row ids of the test
  set.

- `truth`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  True (observed) response.

- `response`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Vector of numeric response values. One element for each observation in
  the test set.

- `se`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Numeric vector of predicted standard errors. One element for each
  observation in the test set.

- `quantiles`:

  ([`matrix()`](https://rdrr.io/r/base/matrix.html))  
  Numeric matrix of predicted quantiles. One row per observation, one
  column per quantile.

- `distr`:

  (`VectorDistribution`)  
  `VectorDistribution` from package distr6 (in repository
  <https://raphaels1.r-universe.dev>).

- `weights`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Vector of measure weights for each observation.

- `check`:

  (`logical(1)`)  
  If `TRUE`, performs some argument checks and predict type conversions.

- `extra`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list carrying the order (time) column and any key columns of the
  forecast horizon. The list names are the original task column names.

- `raw`:

  (any)  
  Raw prediction object from the upstream model. Stored as-is without
  validation.

------------------------------------------------------------------------

### `PredictionFcst$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PredictionFcst$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
task = tsk("airpassengers")
learner = lrn("fcst.auto_arima")$train(task)
p = forecast(learner, task, h = 12)
p$predict_types
#> [1] "response"
head(as.data.table(p))
#>         month row_ids truth response
#>        <Date>   <int> <num>    <num>
#> 1: 1961-01-01       1    NA 445.6349
#> 2: 1961-02-01       2    NA 420.3950
#> 3: 1961-03-01       3    NA 449.1983
#> 4: 1961-04-01       4    NA 491.8399
#> 5: 1961-05-01       5    NA 503.3945
#> 6: 1961-06-01       6    NA 566.8625
```
