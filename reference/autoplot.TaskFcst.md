# Plot for Forecast Tasks

Generates plots for
[TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md).

## Usage

``` r
autoplot.TaskFcst(
  object,
  theme = ggplot2::theme_minimal(),
  facets = FALSE,
  ...
)
```

## Arguments

- object:

  ([TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md)).

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
ggplot2::autoplot(task)
```
