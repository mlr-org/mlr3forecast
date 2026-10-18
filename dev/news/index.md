# Changelog

## mlr3forecast (development version)

- BREAKING CHANGE: The `smooth` learners no longer offer the multistep
  losses `MSEh`, `TMSE`, `GTMSE`, `MSCE`, and `GPL` or the `holdout`
  parameter, which all need a forecast horizon at training time and
  failed with the learners’ horizon of 0. `fcst.sparma` also drops the
  `LASSO` and `RIDGE` losses, which
  [`smooth::sparma()`](https://rdrr.io/pkg/smooth/man/sparma.html) does
  not implement.
- BREAKING CHANGE: `freq` is now only the step of the time index, a
  calendar string such as `"month"` for a `Date` or `POSIXct` order
  column, a number for a numeric or integer one, or `NULL` to infer it.
  A numeric `freq` used to set the seasonal period and now errors on a
  `Date` or `POSIXct` order column, set the new `period` hyperparameter
  instead.
- BREAKING CHANGE: `as.ts.TaskFcst()` takes `period` instead of `freq`.
  [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/dev/reference/as_task_fcst.md)
  gives a `ts` without a calendar step, e.g. of frequency 7 or 260, an
  integer `index` column as order instead of made-up timestamps, and
  warns that its frequency is not kept.
- BREAKING CHANGE: `DirectForecaster` and `RecursiveForecaster` now
  default to the id of the wrapped learner with the suffix `.direct` or
  `.recursive`, instead of reusing the id of the wrapped learner or
  graph, so a forecaster and the learner it wraps no longer share an id
  in benchmarks.
- BREAKING CHANGE:
  [`download_zenodo_record()`](https://mlr3forecast.mlr-org.com/dev/reference/download_zenodo_record.md)
  no longer defaults to the M3 yearly dataset. Both `record_id` and
  `dataset_name` must be supplied.
- BREAKING CHANGE:
  [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/dev/reference/as_task_fcst.md)
  and `TaskFcst$new()` infer `freq` on construction if it is not given,
  so `task$freq` is never `NULL` and the default seasonal `period` no
  longer depends on whether `freq` was set. If the step cannot be
  inferred, i.e. for series with different steps, an irregular order
  column, or a `Date` or `POSIXct` order column without a series of two
  observations, construction errors and asks for `freq`. The step no
  longer changes when rows are filtered, e.g. a task filtered to a
  single row no longer forecasts daily dates. A numeric or integer order
  column always gets a step, the greatest common divisor of the gaps for
  whole numbers and `1` for single observations, and series with
  different steps are an error.
- BREAKING CHANGE:
  [`partition()`](https://mlr3.mlr-org.com/reference/partition.html) on
  a forecast task now orders a three-way split chronologically as
  training, validation, and test set, so the test set is the most recent
  data and follows the rows used for fitting and validation. Previously,
  the validation set came after the test set, so a `RecursiveForecaster`
  with this predefined validation set failed to predict the test set.
- BREAKING CHANGE: `po("fcst.targetboxcox")`, `po("fcst.targetdiff")`,
  and `po("fcst.targetscale")` now take and return a `TaskFcst` instead
  of any `TaskRegr`, so a `GraphLearner` built around them with
  `ppl("targettrafo")` is a forecast learner and can be benchmarked
  against the classical forecast learners. In turn, it can no longer
  share a
  [`benchmark()`](https://mlr3.mlr-org.com/reference/benchmark.html)
  call with plain regression learners or graphs, unless these are
  created with `GraphLearner$new(graph, task_type = "fcst")`.
- feat: The `smooth` learners gained the `"gradient"` level of
  `initial`, and `fcst.adam`, `fcst.auto_adam` and `fcst.es` gained the
  `smoother` parameter. This raises the required `smooth` version to
  4.5.2.
- feat: The forecast learners that fit on a `ts`,
  `po("fcst.targetboxcox")`, and `po("fcst.tsfeats")` gained a `period`
  hyperparameter that defaults to the seasonal period implied by the
  task’s `freq`.
- feat: `period` hyperparameters accept a cycle name resolved against
  `freq`, e.g. `period = "year"` on hourly data means `8766`.
- feat: [`as_task()`](https://mlr3.mlr-org.com/reference/as_task.html)
  now converts objects returned by
  [`read_tsf()`](https://mlr3forecast.mlr-org.com/dev/reference/read_tsf.md)
  to forecast tasks.
- feat:
  [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/dev/reference/as_task_fcst.md)
  and `TaskFcst$new()` check a given `freq` against the order column and
  error if an observation is off its grid, if it is finer than the
  spacing of the data (e.g. `"day"` on monthly data), or if it is
  sub-daily on a `Date` column.
- feat:
  [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/dev/reference/as_task_fcst.md)
  derives `freq` from a tsibble’s `yearweek`, `yearmonth`, or
  `yearquarter` index.
- feat:
  [`default_fallback()`](https://mlr3.mlr-org.com/reference/default_fallback.html)
  support for both forecasters, enabling `resample(encapsulate =)`
  without an explicit fallback.
- feat: `DirectForecaster` and
  [`direct_forecaster()`](https://mlr3forecast.mlr-org.com/dev/reference/direct_forecaster.md)
  gained the `clone_graph` argument, matching `RecursiveForecaster`.
- feat: `DirectForecaster` and `RecursiveForecaster` gained a read-only
  `$graph_model` field that exposes their wrapped graph or trained
  graphs.
- feat: `DirectForecaster` and `RecursiveForecaster` gained `$quantiles`
  and `$quantile_response` fields that configure every compatible
  learner in the wrapped graph.
- feat:
  [`download_monash_dataset()`](https://mlr3forecast.mlr-org.com/dev/reference/download_monash_dataset.md)
  downloads Monash Forecasting Repository datasets by dataset ID from
  pinned Zenodo records and sets the `"horizon"` attribute from the
  Monash benchmark horizons for datasets whose tsf file lacks a
  `@horizon` line.
- feat:
  [`download_monash_dataset()`](https://mlr3forecast.mlr-org.com/dev/reference/download_monash_dataset.md)
  and `tsk("monash")` cache downloaded files if the new option
  `mlr3forecast.cache` is set to `TRUE` or a directory.
- feat: `fcst.auto_adam` gained the `constant`, `loss`, and `lambda`
  parameters, which are passed on to
  [`smooth::auto.adam()`](https://rdrr.io/pkg/smooth/man/adam.html).
- feat: New learners `fcst.dotm`, `fcst.dstm`, `fcst.otm`,
  `fcst.stheta`, and `fcst.stm` wrap the theta methods from
  `forecTheta`.
- feat: `fcst.elm` and `fcst.mlp` now use numeric, integer, and logical
  task features as exogenous regressors and gained the `xreg.lags` and
  `xreg.keep` parameters.
- feat: `fcst.es` and `fcst.msarima` gained the `LASSO` and `RIDGE`
  losses together with their penalty weight `lambda`.
- feat: New `po("fcst.targetscale")` centers and scales the target with
  each series’ own mean and standard deviation, or median and median
  absolute deviation with `robust = TRUE`, so global forecasters can
  learn across series on different scales. Response, standard error, and
  quantile predictions are inverted back to the original scale.
- feat: New learner `fcst.esn` wraps
  [`echos::train_esn()`](https://ahaeusser.github.io/echos/reference/train_esn.html)
  for echo state network forecasts with response and quantile
  prediction.
- feat: New learner `fcst.imapa` wraps
  [`tsintermittent::imapa()`](https://rdrr.io/pkg/tsintermittent/man/imapa.html)
  for intermittent demand forecasting with temporal aggregation.
- feat: `fcst.nnetar` gained the `decay`, `maxit`, `rang`, `skip`,
  `MaxNWts`, `abstol`, and `reltol` parameters, which are passed on to
  [`nnet::nnet()`](https://rdrr.io/pkg/nnet/man/nnet.html).
- feat: New learner `fcst.snaive` provides the seasonal naive forecast
  with the seasonal period taken from the `period` hyperparameter, which
  defaults to the period implied by the task’s `freq`.
- feat:
  [`list_monash_datasets()`](https://mlr3forecast.mlr-org.com/dev/reference/list_monash_datasets.md)
  lists the Monash Forecasting Repository datasets available to
  [`download_monash_dataset()`](https://mlr3forecast.mlr-org.com/dev/reference/download_monash_dataset.md)
  and `tsk("monash")`, including their download sizes.
- feat: `tgen("arima")` simulates ARIMA series into a forecast task.
- feat: `tsk("monash", dataset = ...)` creates a forecast task from a
  Monash Forecasting Repository dataset.
- fix:
  [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/dev/reference/as_task_fcst.md)
  and `TaskFcst$new()` now infer a month-end series as monthly (likewise
  quarterly and yearly) and daily local clock times in a time zone with
  daylight saving time as `"1 DSTday"`, instead of leaving `freq` unset.
  [`generate_newdata()`](https://mlr3forecast.mlr-org.com/dev/reference/generate_newdata.md),
  [`forecast()`](https://generics.r-lib.org/reference/forecast.html),
  and the forecasters keep a month-end series on month ends, e.g. April
  30 is followed by May 31 instead of May 30.
- fix: The default seasonal `period` is now rounded to a whole number,
  e.g. `52` instead of `52.18` for a weekly `freq`, so that `fcst.stlm`,
  `fcst.theta`, and other learners requiring an integer period no longer
  drop the seasonality. Set `period = "year"` to keep the exact cycle.
- fix: A daily `freq` now derives a seasonal period of `7` (the weekly
  cycle) instead of the non-integer `365.25`, which blocked seasonal
  models and made scaled measures return `NaN`. Pass `period` explicitly
  to keep the annual cycle. Scores and fitted models change for daily
  tasks.
- fix: The “no model stored” error is now a learner error instead of an
  input error.
- fix: Forecast learners now convert logical exogenous features to
  numeric values before passing them to the wrapped forecasting
  packages.
- fix: Exogenous learners from `smooth` no longer advertise support for
  missing feature values.
- fix: Forecaster hashes now cover the wrapped graph’s structure and,
  for `DirectForecaster`, the `horizons`.
- fix: Learners wrapping the `forecast` package now return correct
  quantiles close to the median and support extreme quantiles.
- fix:
  [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/dev/reference/as_task_fcst.md)
  coerces whole-number numeric attributes of tsf data to integer key
  columns, so datasets such as the Monash `cif_2016` dataset can be
  converted.
- fix:
  [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/dev/reference/as_task_fcst.md)
  now converts tsibbles with several measured variables, keeping the
  non-target ones as features and numeric indices as numbers.
- fix: `DirectForecaster` no longer ignores predict parameters changed
  after training.
- fix: `DirectForecaster` and `RecursiveForecaster` now error in
  `$native_model` on marshaled models instead of returning wrong
  objects.
- fix: `DirectForecaster` and `RecursiveForecaster` now set `$man` to
  their own help pages, so `$help()` no longer opens the `GraphLearner`
  page.
- fix:
  [`download_zenodo_record()`](https://mlr3forecast.mlr-org.com/dev/reference/download_zenodo_record.md)
  is deprecated in favor of
  [`download_monash_dataset()`](https://mlr3forecast.mlr-org.com/dev/reference/download_monash_dataset.md)
  and warns on each call.
- fix: `fcst.adam` gained the `lambda` parameter, the weight of the
  `LASSO` and `RIDGE` penalties. Previously, these losses always used a
  weight of 0 and fit like plain `MSE`.
- fix: `fcst.arfima`, `fcst.auto_arima`, and `fcst.mean` now declare
  dependencies for parameters that only affect exhaustive search or
  bootstrap prediction.
- fix: `fcst.arfima` and `fcst.auto_arima` no longer switch on
  `parallel` via
  [`set_threads()`](https://mlr3.mlr-org.com/reference/set_threads.html)
  during stepwise search, where
  [`forecast::auto.arima()`](https://pkg.robjhyndman.com/forecast/reference/auto.arima.html)
  warned and fit in serial.
- fix: The model call stored by `fcst.ces`, `fcst.es`, `fcst.gum`,
  `fcst.msarima`, `fcst.sma`, `fcst.ssarima`, `fcst.auto_ces`,
  `fcst.auto_gum`, and `fcst.auto_ssarima` now names the target series
  instead of internal code, so printed models are readable.
- fix: `fcst.stlm` initializes `method` to `"ets"`, so `etsmodel` and
  `allow.multiplicative.trend` can be set without setting `method`
  first.
- fix: `fcst.stlm` now raises a configuration error instead of an input
  error for features without `method = "arima"`.
- fix: `fcst.struct_ts` no longer declares `"level"` as the default of
  `type`, since
  [`stats::StructTS()`](https://rdrr.io/r/stats/StructTS.html) fits
  `"BSM"` for seasonal series and `"trend"` otherwise.
- fix:
  [`generate_newdata()`](https://mlr3forecast.mlr-org.com/dev/reference/generate_newdata.md)
  keeps an integer time index integer instead of sometimes returning
  doubles.
- fix: `msr("fcst.wape")` now ignores rows with a missing prediction in
  the denominator too, which previously understated the error.
- fix:
  [`read_tsf()`](https://mlr3forecast.mlr-org.com/dev/reference/read_tsf.md)
  no longer prints the frequency and horizon of the file, which remain
  available as attributes of the returned object.
- fix: `RecursiveForecaster` now returns predictions in the task’s row
  order instead of sorted by key and time, which fixes misaligned truth
  under target trafos and lets `po("fcst.avg")` combine it with
  `DirectForecaster`.
- fix: `rsmp("fcst.cv")` and `rsmp("fcst.holdout")` now reject grouped
  tasks instead of creating invalid time-based splits.
- perf:
  [`read_tsf()`](https://mlr3forecast.mlr-org.com/dev/reference/read_tsf.md)
  builds calendar date indices arithmetically instead of through
  [`ISOdate()`](https://rdrr.io/r/base/ISOdatetime.html), which makes
  reading files with many series about 20 times faster.
- perf: `RecursiveForecaster` now predicts all keys jointly per step
  instead of row by row, making keyed prediction roughly `n_keys` times
  faster.

## mlr3forecast 0.2.0

CRAN release: 2026-08-24

- BREAKING CHANGE: Key columns are no longer features by default.
  Restore the feature role explicitly when needed.
- BREAKING CHANGE: `po("fcstavg")` was renamed to `po("fcst.avg")` to
  match the id prefix of the other PipeOps.
- feat: `DirectForecaster` gained `$importance()`,
  `$selected_features()`, and `$oob_error()` methods returning one
  result per horizon model, named like `$native_model`.
- feat: New learner `fcst.ar` wrapping
  [`stats::ar()`](https://rdrr.io/r/stats/ar.html), fitting
  autoregressive models by Yule-Walker, Burg, OLS, or maximum likelihood
  with optional AIC order selection.
- feat: `fcst.mean` gained the `bootstrap` and `npaths` parameters for
  empirical quantiles resampled from the residuals.
- feat: New learner `fcst.sparma` wrapping
  [`smooth::sparma()`](https://rdrr.io/pkg/smooth/man/sparma.html),
  fitting sparse ARMA models whose `orders` map to specific lags instead
  of expanding polynomials.
- feat:
  [`forecast()`](https://generics.r-lib.org/reference/forecast.html) now
  validates `newdata` as a data frame with unique column names.
- feat:
  [`partition()`](https://mlr3.mlr-org.com/reference/partition.html) now
  validates `ratio` before partitioning a `TaskFcst`.
- feat:
  [`mlr3::set_threads()`](https://mlr3.mlr-org.com/reference/set_threads.html)
  support: the `num.cores` parameter of `fcst.arfima`,
  `fcst.auto_arima`, `fcst.nnetar`, `fcst.bats`, and `fcst.tbats` now
  carries the `"threads"` tag, and setting `num.cores` to a value
  greater than one enables the corresponding parallel switch at train
  time.
- feat:
  [`pipeline_fcst_local()`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_graphs_fcst.local.md)
  now accepts any object supported by
  [`as_graph()`](https://mlr3pipelines.mlr-org.com/reference/as_graph.html)
  and validates `key`.
- feat: `PredictionFcst` now stores explicit roles for extra columns in
  `$col_roles`, replacing type-based detection
  ([\#52](https://github.com/mlr-org/mlr3forecast/issues/52)).
- feat: `RecursiveForecaster` now supports validation and internal
  tuning (configure with
  [`set_validate()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html))
  and delegates `$importance()`, `$selected_features()`, and
  `$oob_error()` to the wrapped graph.
- feat: `TaskFcst` now accepts character or integer keys, while tsibble,
  tsf, and tsbox converters preserve their types.
- fix: `fcst.nnetar` now declares `nnet` in its packages so parallel
  training finds `predict.nnet` on the main process.
- fix: Numeric `freq` values now represent the seasonal period, while
  the grid step is inferred from the order column.
- fix: Both forecasters no longer advertise learner properties they
  cannot honour, fixing failures when tuning with `AutoTuner`. This
  drops the hotstart properties for both and additionally validation,
  internal tuning, importance, selected features, and OOB error for
  `DirectForecaster`.
- fix: `default_measures("fcst")` now returns `regr.mse`, so forecast
  resampling and benchmark results can be aggregated without an explicit
  measure.
- fix: `DirectForecaster` now rejects empty or duplicate `horizons`
  values.
- fix: `fcst.arima`, `fcst.auto_adam`, `fcst.ets`, `fcst.gum`,
  `fcst.rlgt`, and `fcst.stlm` parameter definitions now match the
  wrapped functions’ defaults, ranges, and dependencies.
- fix: `fcst.mase`, `fcst.msis`, and `fcst.rmsse` now infer `period`
  from `task$freq` unless it is set.
- fix: `fcst.nnetar` now supports quantile predictions and uses
  `bootstrap`, `npaths`, and `innov` when simulating their prediction
  intervals.
- fix: `fcst.prophet` now supports logistic growth through a required
  `cap` task feature and an optional `floor` task feature.
- fix: `fcst.sma` now fits the complete training task and no longer
  exposes the incompatible `holdout` parameter.
- fix: `fcst.tslm` now omits `season` from its generated default formula
  for nonseasonal tasks.
- fix: `PipeOpFcstAvg` now declares its required packages and the
  `"fcst"` tag instead of dropping them.
- fix: `rsmp("fcst.holdout", n = 0)` now puts no observations into the
  training set instead of all of them.

## mlr3forecast 0.1.0

CRAN release: 2026-07-22

- Initial CRAN submission.
