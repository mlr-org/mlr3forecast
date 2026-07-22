# Plot for Forecast Predictions

Generates a forecast plot for
[PredictionFcst](https://mlr3forecast.mlr-org.com/dev/reference/PredictionFcst.md).
The point forecast is drawn over the time index. When a `task` is
supplied, the historical series is overlaid and the forecast region is
drawn in a distinct colour, connected to the last historical observation
for visual continuity.

For quantile forecasts, symmetric quantile pairs (e.g. the 10% and 90%
quantiles) are drawn as shaded central prediction interval ribbons over
the forecast region, shaded darker for narrower intervals and labelled
by their level (e.g. 80, 95) in a legend. Quantiles without a symmetric
partner are not drawn.

## Usage

``` r
# S3 method for class 'PredictionFcst'
autoplot(
  object,
  task = NULL,
  theme = ggplot2::theme_minimal(),
  facets = FALSE,
  ...
)
```

## Arguments

- object:

  ([PredictionFcst](https://mlr3forecast.mlr-org.com/dev/reference/PredictionFcst.md)).

- task:

  ([TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md)
  \| `NULL`)  
  Optional task providing the historical series to overlay. When `NULL`,
  only the forecast region is drawn.

- theme:

  ([`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html))  
  The
  [`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
  is applied by default to all plots.

- facets:

  (`logical(1)`)  
  For keyed tasks, draw one panel per series instead of one coloured
  line per series. Default `FALSE`.

- ...:

  (`any`)  
  Additional argument, passed down to the underlying `geom` or plot
  functions.

## Value

[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
task = tsk("airpassengers")
learner = lrn("fcst.auto_arima")$train(task)
p = forecast(learner, task, h = 12)
ggplot2::autoplot(p, task = task)
```
