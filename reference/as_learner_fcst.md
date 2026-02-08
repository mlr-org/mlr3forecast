# Convert to a Forecast Learner

Convert to a Forecast Learner

## Usage

``` r
as_learner_fcst(learner, lags)
```

## Arguments

- learner:

  ([mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html))  
  The regression learner to wrap.

- lags:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The lag values to use for creating lag features.

## Value

[ForecastLearner](https://mlr3forecast.mlr-org.com/reference/ForecastLearner.md).
