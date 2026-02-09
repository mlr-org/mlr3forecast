# Encapsulate a Learner as a Forecast Learner

The ForecastLearner wraps a
[mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html).

## Super class

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
`ForecastLearner`

## Active bindings

- `learner`:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html))  
  The wrapped learner.

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The lags to create.

- `param_set`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Set of hyperparameters.

## Methods

### Public methods

- [`ForecastLearner$new()`](#method-ForecastLearner-new)

- [`ForecastLearner$print()`](#method-ForecastLearner-print)

- [`ForecastLearner$clone()`](#method-ForecastLearner-clone)

Inherited methods

- [`mlr3::Learner$base_learner()`](https://mlr3.mlr-org.com/reference/Learner.html#method-base_learner)
- [`mlr3::Learner$configure()`](https://mlr3.mlr-org.com/reference/Learner.html#method-configure)
- [`mlr3::Learner$encapsulate()`](https://mlr3.mlr-org.com/reference/Learner.html#method-encapsulate)
- [`mlr3::Learner$format()`](https://mlr3.mlr-org.com/reference/Learner.html#method-format)
- [`mlr3::Learner$help()`](https://mlr3.mlr-org.com/reference/Learner.html#method-help)
- [`mlr3::Learner$predict()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict)
- [`mlr3::Learner$predict_newdata()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict_newdata)
- [`mlr3::Learner$reset()`](https://mlr3.mlr-org.com/reference/Learner.html#method-reset)
- [`mlr3::Learner$selected_features()`](https://mlr3.mlr-org.com/reference/Learner.html#method-selected_features)
- [`mlr3::Learner$train()`](https://mlr3.mlr-org.com/reference/Learner.html#method-train)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ForecastLearner$new(learner, lags)

#### Arguments

- `learner`:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html))  
  The regression learner to wrap.

- `lags`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The lag values to use for creating lag features. Printer.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

#### Usage

    ForecastLearner$print()

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ForecastLearner$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
