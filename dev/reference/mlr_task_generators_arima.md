# ARIMA Forecast Task Generator

A [TaskGenerator](https://mlr3.mlr-org.com/reference/TaskGenerator.html)
that simulates series from an ARIMA process via
[`stats::arima.sim()`](https://rdrr.io/r/stats/arima.sim.html), with
autoregressive coefficients `ar`, moving average coefficients `ma`,
differencing order `d`, and innovation standard deviation `sd`.

## Dictionary

This
[TaskGenerator](https://mlr3.mlr-org.com/reference/TaskGenerator.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_task_generators](https://mlr3.mlr-org.com/reference/mlr_task_generators.html)
or with the associated sugar function
[tgen()](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_task_generators$get("arima")
    tgen("arima")

## Parameters

|       |         |         |                  |
|-------|---------|---------|------------------|
| Id    | Type    | Default | Range            |
| ar    | untyped | \-      | \-               |
| d     | integer | \-      | \\\[0, \infty)\\ |
| ma    | untyped | \-      | \-               |
| sd    | numeric | \-      | \\\[0, \infty)\\ |
| k     | integer | \-      | \\\[1, \infty)\\ |
| freq  | untyped | \-      | \-               |
| start | untyped | \-      | \-               |

## Task structure

The generated
[TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md)
has the target `y` and the order column `time`, a regular index starting
at `start` with step `freq`. A calendar `freq` such as `"month"` yields
dates, a numeric `freq` yields the integers `1, ..., n` with `freq` as
the seasonal period. With `k > 1`, `k` independent series are stacked
into a keyed panel with the key column `series`, so `n` is the length of
each series and the task has `n * k` rows.

## See also

- [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of
  [TaskGenerators](https://mlr3.mlr-org.com/reference/TaskGenerator.html):
  [mlr3::mlr_task_generators](https://mlr3.mlr-org.com/reference/mlr_task_generators.html)

- `as.data.table(mlr_task_generators)` for a table of available
  [TaskGenerators](https://mlr3.mlr-org.com/reference/TaskGenerator.html)
  in the running session (depending on the loaded packages).

## Super class

[`mlr3::TaskGenerator`](https://mlr3.mlr-org.com/reference/TaskGenerator.html)
-\> `TaskGeneratorArima`

## Methods

### Public methods

- [`TaskGeneratorArima$new()`](#method-TaskGeneratorArima-initialize)

- [`TaskGeneratorArima$clone()`](#method-TaskGeneratorArima-clone)

Inherited methods

- [`mlr3::TaskGenerator$format()`](https://mlr3.mlr-org.com/reference/TaskGenerator.html#method-format)
- [`mlr3::TaskGenerator$generate()`](https://mlr3.mlr-org.com/reference/TaskGenerator.html#method-generate)
- [`mlr3::TaskGenerator$print()`](https://mlr3.mlr-org.com/reference/TaskGenerator.html#method-print)

------------------------------------------------------------------------

### `TaskGeneratorArima$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    TaskGeneratorArima$new()

------------------------------------------------------------------------

### `TaskGeneratorArima$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TaskGeneratorArima$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
generator = tgen("arima")
task = generator$generate(60)
task$head()
#>           y
#>       <num>
#> 1: 1.580073
#> 2: 2.033731
#> 3: 1.528938
#> 4: 2.331455
#> 5: 2.177664
#> 6: 2.020195

# random walk, 3 series
generator = tgen("arima", ar = numeric(), d = 1L, k = 3L)
task = generator$generate(24)
task
#> 
#> ── <TaskFcst> (72x1) ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#> • Target: y
#> • Properties: ordered, keys
#> • Order by: time
#> • Key by: series
#> • Frequency: month
```
