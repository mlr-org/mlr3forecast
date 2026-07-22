# Forecast from a Trained Learner

Generates `h` future rows from the task's skeleton (using
[`generate_newdata()`](https://mlr3forecast.mlr-org.com/dev/reference/generate_newdata.md)),
optionally overlays user-supplied `newdata` onto those rows, and
predicts with the trained learner via
[mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)`$predict_newdata()`.
Works with
[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md),
[DirectForecaster](https://mlr3forecast.mlr-org.com/dev/reference/DirectForecaster.md),
and classic `LearnerFcst*` forecasters.

## Usage

``` r
# S3 method for class 'Learner'
forecast(object, task, h = 12L, newdata = NULL, ...)
```

## Arguments

- object:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html))  
  A trained forecast learner.

- task:

  ([TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md))  
  Provides the metadata needed to construct future rows: the order
  column (to extend the time index), key columns (for keyed tasks),
  `freq`, and the column-type schema expected by `predict_newdata()`.
  The task's data values are not used. Pass the training task or any
  other schema-compatible
  [TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md).

- h:

  (`integer(1)`)  
  Forecast horizon — number of future time steps per key.

- newdata:

  ([`data.frame()`](https://rdrr.io/r/base/data.frame.html) \| `NULL`)  
  Optional exogenous features for future rows. Must contain the order
  column (and any key columns for keyed tasks), and every row must match
  a row of the generated future grid. Columns other than those are
  overlaid onto the generated skeleton, while skeleton rows without a
  match keep `NA`.

- ...:

  (any)  
  Ignored.

## Value

[mlr3::Prediction](https://mlr3.mlr-org.com/reference/Prediction.html).
