# Download a Monash Forecasting Repository dataset

Downloads a dataset of the Monash Forecasting Repository from Zenodo and
parses it with
[`read_tsf()`](https://mlr3forecast.mlr-org.com/dev/reference/read_tsf.md).
The catalog pins the Zenodo record for each dataset version listed at
<https://forecastingdata.org/>. The dataset ID is the name of the Zenodo
file without the `"_dataset"` and `"_without_missing_values"` suffixes,
so variants that keep missing values end in `"_with_missing_values"`.
Downloaded files are cached if the option `mlr3forecast.cache` is set,
see
[mlr3forecast](https://mlr3forecast.mlr-org.com/dev/reference/mlr3forecast-package.md).

## Usage

``` r
download_monash_dataset(dataset)
```

## Arguments

- dataset:

  (`character(1)`)  
  The Monash dataset ID, e.g. `"m3_yearly"`. See
  [`list_monash_datasets()`](https://mlr3forecast.mlr-org.com/dev/reference/list_monash_datasets.md)
  for the available IDs and their download sizes.

## Value

([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))
with class `"tsf"`. If the file contains a frequency or horizon, the
`"frequency"` and `"horizon"` attributes are set, respectively. For
datasets whose file lacks a `@horizon` line, the `"horizon"` attribute
is filled from the forecast horizon used in the Monash benchmark
experiments, if one exists for that dataset.

## References

Godahewa R, Bergmeir C, Webb GI, Hyndman RJ, Montero-Manso P (2021).
“Monash time series forecasting archive.” *arXiv preprint
arXiv:2105.06643*.

## Examples

``` r
if (FALSE) { # \dontrun{
library(data.table)
dt = download_monash_dataset("m3_yearly")

# optional renaming
setnames(dt, c("id", "date", "value"))

# transform into single task
task = as_task_fcst(dt)

# or split up for forecast learners that don't allow key columns
tasks = as_tasks_fcst(split(dt, by = "id", keep.by = FALSE))

# benchmark
learners = lrns(c("fcst.auto_arima", "fcst.ets", "fcst.random_walk"))
resampling = rsmp("fcst.holdout", ratio = 0.8)
design = benchmark_grid(tasks, learners, resampling)
bmr = benchmark(design)
bmr$aggregate(msr("regr.rmse"))[, .(rmse = mean(regr.rmse)), by = learner_id]
} # }
```
