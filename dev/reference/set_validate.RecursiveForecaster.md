# Configure Validation for a RecursiveForecaster

Sets the `$validate` field of the forecaster, which controls *how* the
validation data is constructed, and configures the wrapped graph so its
base learner uses it via
[`mlr3pipelines::set_validate.GraphLearner()`](https://mlr3pipelines.mlr-org.com/reference/set_validate.GraphLearner.html).
See [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html) for
the meaning of `validate`. Errors if no learner in the graph supports
validation.

## Usage

``` r
# S3 method for class 'RecursiveForecaster'
set_validate(learner, validate, ...)
```

## Arguments

- learner:

  ([RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md))  
  The forecaster to configure.

- validate:

  (`numeric(1)` \| `"predefined"` \| `"test"` \| `NULL`)  
  How to construct the internal validation data.

- ...:

  (any)  
  Passed to
  [`mlr3pipelines::set_validate.GraphLearner()`](https://mlr3pipelines.mlr-org.com/reference/set_validate.GraphLearner.html),
  e.g. `ids`, `args_all`, and `args`.

## Value

[RecursiveForecaster](https://mlr3forecast.mlr-org.com/dev/reference/RecursiveForecaster.md),
invisibly.
