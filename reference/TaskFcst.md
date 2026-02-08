# Forecast Task

This task specializes
[mlr3::Task](https://mlr3.mlr-org.com/reference/Task.html),
[mlr3::TaskSupervised](https://mlr3.mlr-org.com/reference/TaskSupervised.html)
and [mlr3::TaskRegr](https://mlr3.mlr-org.com/reference/TaskRegr.html)
for forecasting problems. The target column is assumed to be numeric.
The `task_type` is set to `"fcst"`.

It is recommended to use
[`as_task_fcst()`](https://mlr3forecast.mlr-org.com/reference/as_task_fcst.md)
for construction. Predefined tasks are stored in the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_tasks](https://mlr3.mlr-org.com/reference/mlr_tasks.html).

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
[`mlr_tasks_airpassengers`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_airpassengers.md),
[`mlr_tasks_electricity`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_electricity.md),
[`mlr_tasks_livestock`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_livestock.md),
[`mlr_tasks_lynx`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_lynx.md),
[`mlr_tasks_usaccdeaths`](https://mlr3forecast.mlr-org.com/reference/mlr_tasks_usaccdeaths.md)

## Super classes

[`mlr3::Task`](https://mlr3.mlr-org.com/reference/Task.html) -\>
[`mlr3::TaskSupervised`](https://mlr3.mlr-org.com/reference/TaskSupervised.html)
-\> [`mlr3::TaskRegr`](https://mlr3.mlr-org.com/reference/TaskRegr.html)
-\> `TaskFcst`

## Public fields

- `freq`:

  (`character(1)`)  
  The frequency of the time series.

## Active bindings

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of task properties. Possible properties are stored in
  [mlr_reflections\$task_properties](https://mlr3.mlr-org.com/reference/mlr_reflections.html).
  The following properties are currently standardized and understood by
  tasks in [mlr3](https://CRAN.R-project.org/package=mlr3):

  - `"strata"`: The task is resampled using one or more stratification
    variables (role `"stratum"`).

  - `"groups"`: The task comes with grouping/blocking information (role
    `"group"`).

  - `"weights"`: The task comes with observation weights (role
    `"weight"`).

  - `"ordered"`: The task has columns which define the row order (role
    `"order"`).

  - `"keys"`: The task has columns which define the time series `"key"`.

  Note that above listed properties are calculated from the `$col_roles`
  and may not be set explicitly.

- `order`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
  If the task has a column with designated role `"order"`, a table with
  two or more columns:

  - `row_id` ([`integer()`](https://rdrr.io/r/base/integer.html)), and

  - `order` (`Date()` \| `POSIXct()` \|
    [`numeric()`](https://rdrr.io/r/base/numeric.html)).

  Returns `NULL` if there is no order column.

- `key`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
  If the task has a column with designated role `"key"`, a table with
  two or more columns:

  - `row_id` ([`integer()`](https://rdrr.io/r/base/integer.html)), and

  - key variable(s) ([`factor()`](https://rdrr.io/r/base/factor.html)).

  If there is only one key column, it will be named as `key`. Returns
  `NULL` if there are no key columns.

## Methods

### Public methods

- [`TaskFcst$new()`](#method-TaskFcst-new)

- [`TaskFcst$view()`](#method-TaskFcst-view)

- [`TaskFcst$print()`](#method-TaskFcst-print)

- [`TaskFcst$clone()`](#method-TaskFcst-clone)

Inherited methods

- [`mlr3::Task$add_strata()`](https://mlr3.mlr-org.com/reference/Task.html#method-add_strata)
- [`mlr3::Task$cbind()`](https://mlr3.mlr-org.com/reference/Task.html#method-cbind)
- [`mlr3::Task$data()`](https://mlr3.mlr-org.com/reference/Task.html#method-data)
- [`mlr3::Task$divide()`](https://mlr3.mlr-org.com/reference/Task.html#method-divide)
- [`mlr3::Task$droplevels()`](https://mlr3.mlr-org.com/reference/Task.html#method-droplevels)
- [`mlr3::Task$filter()`](https://mlr3.mlr-org.com/reference/Task.html#method-filter)
- [`mlr3::Task$format()`](https://mlr3.mlr-org.com/reference/Task.html#method-format)
- [`mlr3::Task$formula()`](https://mlr3.mlr-org.com/reference/Task.html#method-formula)
- [`mlr3::Task$head()`](https://mlr3.mlr-org.com/reference/Task.html#method-head)
- [`mlr3::Task$help()`](https://mlr3.mlr-org.com/reference/Task.html#method-help)
- [`mlr3::Task$levels()`](https://mlr3.mlr-org.com/reference/Task.html#method-levels)
- [`mlr3::Task$materialize_view()`](https://mlr3.mlr-org.com/reference/Task.html#method-materialize_view)
- [`mlr3::Task$missings()`](https://mlr3.mlr-org.com/reference/Task.html#method-missings)
- [`mlr3::Task$rbind()`](https://mlr3.mlr-org.com/reference/Task.html#method-rbind)
- [`mlr3::Task$rename()`](https://mlr3.mlr-org.com/reference/Task.html#method-rename)
- [`mlr3::Task$select()`](https://mlr3.mlr-org.com/reference/Task.html#method-select)
- [`mlr3::Task$set_col_roles()`](https://mlr3.mlr-org.com/reference/Task.html#method-set_col_roles)
- [`mlr3::Task$set_levels()`](https://mlr3.mlr-org.com/reference/Task.html#method-set_levels)
- [`mlr3::Task$set_row_roles()`](https://mlr3.mlr-org.com/reference/Task.html#method-set_row_roles)
- [`mlr3::TaskRegr$truth()`](https://mlr3.mlr-org.com/reference/TaskRegr.html#method-truth)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class. The function
[`as_task_fcst()`](https://mlr3forecast.mlr-org.com/reference/as_task_fcst.md)
provides an alternative way to construct forecast tasks.

#### Usage

    TaskFcst$new(
      id,
      backend,
      target,
      order,
      key = character(),
      freq = NULL,
      label = NA_character_,
      extra_args = list()
    )

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier for the new instance.

- `backend`:

  ([mlr3::DataBackend](https://mlr3.mlr-org.com/reference/DataBackend.html))  
  Either a
  [mlr3::DataBackend](https://mlr3.mlr-org.com/reference/DataBackend.html),
  or any object which is convertible to a
  [mlr3::DataBackend](https://mlr3.mlr-org.com/reference/DataBackend.html)
  with
  [`as_data_backend()`](https://mlr3.mlr-org.com/reference/as_data_backend.html).
  E.g., a [`data.frame()`](https://rdrr.io/r/base/data.frame.html) will
  be converted to a
  [mlr3::DataBackendDataTable](https://mlr3.mlr-org.com/reference/DataBackendDataTable.html).

- `target`:

  (`character(1)`)  
  Name of the target column.

- `order`:

  (`character(1)`)  
  Name of the order column.

- `key`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Name of the key column.

- `freq`:

  (`character(1)` \| `integer(1)`)  
  Frequency of the time series. Either a positive number or one of the
  following:

  - `"secondly"`

  - `"minutely"`

  - `"hourly"`

  - `"daily"`

  - `"weekly"`

  - `"monthly"`

  - `"quarterly"`

  - `"yearly"`

- `label`:

  (`character(1)`)  
  Label for the new instance.

- `extra_args`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of constructor arguments, required for converting task
  types via
  [`mlr3::convert_task()`](https://mlr3.mlr-org.com/reference/convert_task.html).

------------------------------------------------------------------------

### Method `view()`

Returns a slice of the data from the
[mlr3::DataBackend](https://mlr3.mlr-org.com/reference/DataBackend.html)
as a
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html).
Rows default to observations with role `"use"`, and columns default to
features with roles `"target"`, `"order"`, `"key"` or `"feature"`. If
`rows` or `cols` are specified which do not exist in the
[mlr3::DataBackend](https://mlr3.mlr-org.com/reference/DataBackend.html),
an exception is raised.

Rows and columns are returned in the order specified via the arguments
`rows` and `cols`. If `rows` is `NULL`, rows are returned in the order
of `task$row_ids`. If `cols` is `NULL`, the column order defaults to
`c(task$target_names, task$feature_names, task$col_roles$key, task$col_roles$order)`.
Note that it is recommended to **not** rely on the order of columns, and
instead always address columns with their respective column name.

#### Usage

    TaskFcst$view(rows = NULL, cols = NULL, ordered = FALSE)

#### Arguments

- `rows`:

  (positive [`integer()`](https://rdrr.io/r/base/integer.html))  
  Vector or row indices.

- `cols`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Vector of column names.

- `ordered`:

  (`logical(1)`)  
  If `TRUE`, data is ordered according to the columns with column role
  `"order"` and `"key"`.

#### Returns

A
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Printer.

#### Usage

    TaskFcst$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TaskFcst$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(data.table)
airpassengers = tsbox::ts_dt(AirPassengers)
setnames(airpassengers, c("month", "passengers"))
task = as_task_fcst(airpassengers, target = "passengers", order = "month", freq = "monthly")
task$task_type
#> [1] "fcst"
task$formula()
#> passengers ~ .
#> NULL
task$truth()
#>   [1] 112 118 132 129 121 135 148 148 136 119 104 118 115 126 141 135 125 149
#>  [19] 170 170 158 133 114 140 145 150 178 163 172 178 199 199 184 162 146 166
#>  [37] 171 180 193 181 183 218 230 242 209 191 172 194 196 196 236 235 229 243
#>  [55] 264 272 237 211 180 201 204 188 235 227 234 264 302 293 259 229 203 229
#>  [73] 242 233 267 269 270 315 364 347 312 274 237 278 284 277 317 313 318 374
#>  [91] 413 405 355 306 271 306 315 301 356 348 355 422 465 467 404 347 305 336
#> [109] 340 318 362 348 363 435 491 505 404 359 310 337 360 342 406 396 420 472
#> [127] 548 559 463 407 362 405 417 391 419 461 472 535 622 606 508 461 390 432
```
