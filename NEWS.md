# mlr3forecast (development version)

* fix: A daily `freq` now derives a seasonal period of `7` (the weekly cycle) instead of `365.25` (the annual one). Both are valid seasonal periods for daily data, but `365.25` is unusable as a default: it is non-integer, so `forecast::ets()` and friends refuse to fit seasonal models, and it made `msr("fcst.mase")`, `msr("fcst.rmsse")` and `msr("fcst.msis")` return `NaN` for any daily task with fewer than 365 training observations. `7` is what `tsibble::guess_frequency()`, `fabletools::get_frequencies()` and `statsmodels`' `freq_to_period()` derive. Pass `period` explicitly to keep the annual cycle. Scores and fitted models change for daily tasks.

* feat: `download_zenodo_record()` now sets the `"horizon"` attribute from the Monash benchmark horizons for datasets whose tsf file lacks a `@horizon` line.
* feat: The `smooth` learners gained the `"gradient"` level of `initial`, and `fcst.adam` and `fcst.es` gained the `smoother` parameter. This raises the required `smooth` version to 4.5.1.
* feat: `default_fallback()` support for both forecasters, enabling `resample(encapsulate =)` without an explicit fallback.
* feat: `DirectForecaster` and `RecursiveForecaster` gained a read-only `$graph_model` field that exposes their wrapped graph or trained graphs.
* feat: `DirectForecaster` and `RecursiveForecaster` gained `$quantiles` and `$quantile_response` fields that configure every compatible learner in the wrapped graph.
* fix: Missing-model errors now use their matching structured error class.
* fix: Forecast learners now convert logical exogenous features to numeric values before passing them to the wrapped forecasting packages.
* fix: Exogenous learners from `smooth` no longer advertise support for missing feature values.
* fix: Forecaster hashes now cover the wrapped graph's structure and the `horizons`.
* fix: `DirectForecaster` no longer ignores predict parameters changed after training.
* fix: `fcst.arfima`, `fcst.auto_arima`, and `fcst.mean` now declare dependencies for parameters that only affect exhaustive search or bootstrap prediction.
* fix: `$native_model` now errors on marshaled models instead of returning wrong objects.
* fix: `rsmp("fcst.cv")` and `rsmp("fcst.holdout")` now reject grouped tasks instead of creating invalid time-based splits.
* perf: `RecursiveForecaster` now predicts all keys jointly per step instead of row by row, making keyed prediction roughly `n_keys` times faster.

# mlr3forecast 0.2.0

* BREAKING CHANGE: Key columns are no longer features by default. Restore the feature role explicitly when needed.
* BREAKING CHANGE: `po("fcstavg")` was renamed to `po("fcst.avg")` to match the id prefix of the other PipeOps.
* feat: `DirectForecaster` gained `$importance()`, `$selected_features()`, and `$oob_error()` methods returning one result per horizon model, named like `$native_model`.
* feat: New learner `fcst.ar` wrapping `stats::ar()`, fitting autoregressive models by Yule-Walker, Burg, OLS, or maximum likelihood with optional AIC order selection.
* feat: `fcst.mean` gained the `bootstrap` and `npaths` parameters for empirical quantiles resampled from the residuals.
* feat: New learner `fcst.sparma` wrapping `smooth::sparma()`, fitting sparse ARMA models whose `orders` map to specific lags instead of expanding polynomials.
* feat: `forecast()` now validates `newdata` as a data frame with unique column names.
* feat: `partition()` now validates `ratio` before partitioning a `TaskFcst`.
* feat: `mlr3::set_threads()` support: the `num.cores` parameter of `fcst.arfima`, `fcst.auto_arima`, `fcst.nnetar`, `fcst.bats`, and `fcst.tbats` now carries the `"threads"` tag, and setting `num.cores` to a value greater than one enables the corresponding parallel switch at train time.
* feat: `pipeline_fcst_local()` now accepts any object supported by `as_graph()` and validates `key`.
* feat: `PredictionFcst` now stores explicit roles for extra columns in `$col_roles`, replacing type-based detection (#52).
* feat: `RecursiveForecaster` now supports validation and internal tuning (configure with `set_validate()`) and delegates `$importance()`, `$selected_features()`, and `$oob_error()` to the wrapped graph.
* feat: `TaskFcst` now accepts character or integer keys, while tsibble, tsf, and tsbox converters preserve their types.
* fix: `fcst.nnetar` now declares `nnet` in its packages so parallel training finds `predict.nnet` on the main process.
* fix: Numeric `freq` values now represent the seasonal period, while the grid step is inferred from the order column.
* fix: Both forecasters no longer advertise learner properties they cannot honour, fixing failures when tuning with `AutoTuner`. This drops the hotstart properties for both and additionally validation, internal tuning, importance, selected features, and OOB error for `DirectForecaster`.
* fix: `default_measures("fcst")` now returns `regr.mse`, so forecast resampling and benchmark results can be aggregated without an explicit measure.
* fix: `DirectForecaster` now rejects empty or duplicate `horizons` values.
* fix: `fcst.arima`, `fcst.auto_adam`, `fcst.ets`, `fcst.gum`, `fcst.rlgt`, and `fcst.stlm` parameter definitions now match the wrapped functions' defaults, ranges, and dependencies.
* fix: `fcst.mase`, `fcst.msis`, and `fcst.rmsse` now infer `period` from `task$freq` unless it is set.
* fix: `fcst.nnetar` now supports quantile predictions and uses `bootstrap`, `npaths`, and `innov` when simulating their prediction intervals.
* fix: `fcst.prophet` now supports logistic growth through a required `cap` task feature and an optional `floor` task feature.
* fix: `fcst.sma` now fits the complete training task and no longer exposes the incompatible `holdout` parameter.
* fix: `fcst.tslm` now omits `season` from its generated default formula for nonseasonal tasks.
* fix: `PipeOpFcstAvg` now declares its required packages and the `"fcst"` tag instead of dropping them.
* fix: `rsmp("fcst.holdout", n = 0)` now puts no observations into the training set instead of all of them.

# mlr3forecast 0.1.0

* Initial CRAN submission.
