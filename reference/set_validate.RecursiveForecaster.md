# Configure Validation for a RecursiveForecaster

Sets the `$validate` field of the forecaster, which controls *how* the
validation data is constructed (see
[mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)), and
configures the wrapped graph so its base learner uses it (via
[`mlr3pipelines::set_validate.GraphLearner()`](https://mlr3pipelines.mlr-org.com/reference/set_validate.GraphLearner.html),
the inner PipeOps receive `"predefined"`).

## Usage

``` r
# S3 method for class 'RecursiveForecaster'
set_validate(
  learner,
  validate,
  ids = NULL,
  args_all = list(),
  args = list(),
  ...
)
```

## Arguments

- learner:

  ([RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md))  
  The forecaster to configure.

- validate:

  (`numeric(1)` \| `"predefined"` \| `"test"` \| `NULL`)  
  How to construct the internal validation data.

- ids:

  ([`character()`](https://rdrr.io/r/base/character.html) \| `NULL`)  
  The ids of the PipeOps for which to enable validation, forwarded to
  [`mlr3pipelines::set_validate.GraphLearner()`](https://mlr3pipelines.mlr-org.com/reference/set_validate.GraphLearner.html).
  Defaults to the base learner.

- args_all:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Arguments passed to all
  [`set_validate()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)
  calls of the affected PipeOps.

- args:

  (named [`list()`](https://rdrr.io/r/base/list.html) of named
  [`list()`](https://rdrr.io/r/base/list.html)s)  
  Arguments passed to the
  [`set_validate()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)
  calls of specific PipeOps, named by their ids.

- ...:

  (any)  
  Further arguments passed to
  [`mlr3pipelines::set_validate.GraphLearner()`](https://mlr3pipelines.mlr-org.com/reference/set_validate.GraphLearner.html).

## Value

[RecursiveForecaster](https://mlr3forecast.mlr-org.com/reference/RecursiveForecaster.md),
invisibly.
