# Annual Canadian Lynx Trappings Forecast Task

A forecast task for the popular
[datasets::lynx](https://rdrr.io/r/datasets/lynx.html) data set. The
task represents the annual numbers of lynx trappings in Canada from 1821
to 1934.

## Format

[R6::R6Class](https://r6.r-lib.org/reference/R6Class.html) inheriting
from
[TaskFcst](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md).

## Source

Brockwell PJ, Davis RA (1991). *Time Series: Theory and Methods*, 2nd
edition. Springer, New York.

## Dictionary

This [Task](https://mlr3.mlr-org.com/reference/Task.html) can be
instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_tasks](https://mlr3.mlr-org.com/reference/mlr_tasks.html) or with
the associated sugar function
[tsk()](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_tasks$get("lynx")
    tsk("lynx")

## Meta Information

- Task type: “fcst”

- Dimensions: 114x1

- Properties: “ordered”

- Has Missings: `FALSE`

- Target: “count”

- Features: -

## References

Campbell MJ, Walker AM (1977). “A Survey of Statistical Work on the
Mackenzie River Series of Annual Canadian Lynx Trappings for the Years
1821-1934 and a New Analysis.” *Journal of the Royal Statistical
Society. Series A (General)*, **140**(4), 411–431.
[doi:10.2307/2345277](https://doi.org/10.2307/2345277) .

Becker RA, Chambers JM, Wilks AR (1988). *The New S Language*. Chapman
and Hall/CRC, London.

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
[`TaskFcst`](https://mlr3forecast.mlr-org.com/dev/reference/TaskFcst.md),
[`mlr_tasks_airpassengers`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_tasks_airpassengers.md),
[`mlr_tasks_electricity`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_tasks_electricity.md),
[`mlr_tasks_livestock`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_tasks_livestock.md),
[`mlr_tasks_usaccdeaths`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_tasks_usaccdeaths.md)
