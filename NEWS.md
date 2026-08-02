# mlr3forecast (development version)

* BREAKING CHANGE: Key columns are no longer features by default. Restore the feature role explicitly when needed.
* BREAKING CHANGE: `po("fcstavg")` was renamed to `po("fcst.avg")` to match the id prefix of the other PipeOps.
* Numeric `freq` values now represent the seasonal period, while the grid step is inferred from the order column.
* `DirectForecaster` now rejects empty or duplicate `horizons` values.
* `fcst.mase`, `fcst.msis`, and `fcst.rmsse` now infer `period` from `task$freq` unless it is set.
* `PredictionFcst` now stores explicit roles for extra columns in `$col_roles`, replacing type-based detection.
* `RecursiveForecaster` now supports validation and internal tuning (configure with `set_validate()`) and delegates `$importance()`, `$selected_features()`, and `$oob_error()` to the wrapped graph.
* Both forecasters no longer advertise learner properties they cannot honour, fixing failures when tuning with `AutoTuner`. This drops the hotstart properties for both and additionally validation, internal tuning, importance, selected features, and OOB error for `DirectForecaster`.
* `DirectForecaster` gained `$importance()`, `$selected_features()`, and `$oob_error()` methods returning one result per horizon model, named like `$native_model`.
* `rsmp("fcst.holdout", n = 0)` now puts no observations into the training set instead of all of them.
* `TaskFcst` now accepts character or integer keys, while tsibble, tsf, and tsbox converters preserve their types.

# mlr3forecast 0.1.0

* Initial CRAN submission.
