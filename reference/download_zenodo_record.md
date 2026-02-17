# Download tsf file from Zenodo

Downloads a tsf file from Zenodo using the provided record ID and
dataset name.

## Usage

``` r
download_zenodo_record(record_id = 4656222, dataset_name = "m3_yearly_dataset")
```

## Arguments

- record_id:

  (`integer(1)`)  
  The Zenodo record ID.

- dataset_name:

  (`character(1)`)  
  The name of the dataset to download.

## Value

([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)).

## References

Godahewa, Rakshitha, Bergmeir, Christoph, Webb, I G, Hyndman, J R,
Montero-Manso, Pablo (2021). “Monash time series forecasting archive.”
*arXiv preprint arXiv:2105.06643*.

## Examples

``` r
if (FALSE) { # \dontrun{
dt = download_zenodo_record(record_id = 4656222, dataset_name = "m3_yearly_dataset")

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
