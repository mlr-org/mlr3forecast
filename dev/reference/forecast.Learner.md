# Forecast from a Trained Learner

Generates `h` future observations per series with
[`generate_newdata()`](https://mlr3forecast.mlr-org.com/dev/reference/generate_newdata.md)
and predicts with a trained learner. Optional `newdata` supplies future
feature values.

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
  Task whose last observation in each series is the last one `object`
  was trained on, usually the training task. The learner forecasts from
  the end of its training data, so a task with newer observations
  requires retraining. Its order column, keys, and `freq` define the
  future time grid. Its column types must match those expected by the
  trained learner.

- h:

  (`integer(1)`)  
  Number of future time steps per series.

- newdata:

  ([`data.frame()`](https://rdrr.io/r/base/data.frame.html) \| `NULL`)  
  Optional exogenous features for future rows. Must contain the order
  column (and any key columns for keyed tasks), and every row must match
  a row of the generated future grid. Columns other than those are
  overlaid onto the generated skeleton, while skeleton rows without a
  match keep `NA`. Required if `task` has features, and must then
  contain every feature column.

- ...:

  (any)  
  Must be empty.

## Value

[mlr3::Prediction](https://mlr3.mlr-org.com/reference/Prediction.html).
