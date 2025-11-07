# Air Passengers Forecast Task

A forecast task for the popular
[datasets::AirPassengers](https://rdrr.io/r/datasets/AirPassengers.html)
data set. The task represents the monthly totals of international
airline passengers from 1949 to 1960.

## Format

[R6::R6Class](https://r6.r-lib.org/reference/R6Class.html) inheriting
from [TaskFcst](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md).

## Source

Box, P. GE, Jenkins, M. G, Reinsel, C. G (1976). *Time Series Analysis,
Forecasting and Control*, 3rd edition. Holden-Day. Series G.

## Dictionary

This [Task](https://mlr3.mlr-org.com/reference/Task.html) can be
instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_tasks](https://mlr3.mlr-org.com/reference/mlr_tasks.html) or with
the associated sugar function
[tsk()](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_tasks$get("airpassengers")
    tsk("airpassengers")

## Meta Information

- Task type: “fcst”

- Dimensions: 144x1

- Properties: “ordered”

- Has Missings: `FALSE`

- Target: “passengers”

- Features: -

## See also

- Chapter in the [mlr3book](https://mlr3book.mlr-org.com/):
  <https://mlr3book.mlr-org.com/chapters/chapter2/data_and_basic_modeling.html>

- Package [mlr3data](https://CRAN.R-project.org/package=mlr3data) for
  more toy tasks.

- Package [mlr3oml](https://CRAN.R-project.org/package=mlr3oml) for
  downloading tasks from <https://www.openml.org>.

- Package [mlr3viz](https://CRAN.R-project.org/package=mlr3viz) for some
  generic visualizations.

- [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of [Tasks](https://mlr3.mlr-org.com/reference/Task.html):
  [mlr3::mlr_tasks](https://mlr3.mlr-org.com/reference/mlr_tasks.html)

- `as.data.table(mlr_tasks)` for a table of available
  [Tasks](https://mlr3.mlr-org.com/reference/Task.html) in the running
  session (depending on the loaded packages).

- [mlr3fselect](https://CRAN.R-project.org/package=mlr3fselect) and
  [mlr3filters](https://CRAN.R-project.org/package=mlr3filters) for
  feature selection and feature filtering.

- Extension packages for additional task types:

  - Unsupervised clustering:
    [mlr3cluster](https://CRAN.R-project.org/package=mlr3cluster)

  - Probabilistic supervised regression and survival analysis:
    <https://mlr3proba.mlr-org.com/>.

Other Task:
[`TaskFcst`](https://mlr3forecast.mlr-org.com/reference/TaskFcst.md),
[`mlr_tasks_electricity`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_electricity.md),
[`mlr_tasks_livestock`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_livestock.md),
[`mlr_tasks_lynx`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_lynx.md),
[`mlr_tasks_usaccdeaths`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_usaccdeaths.md)
