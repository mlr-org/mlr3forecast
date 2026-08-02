# mlr3forecast (development version)

* BREAKING CHANGE: Key columns are no longer features by default. Restore the feature role explicitly when needed.
* Numeric `freq` values now represent the seasonal period, while the grid step is inferred from the order column.
* `DirectForecaster` now rejects empty or duplicate `horizons` values.
* `DirectForecaster` and `RecursiveForecaster` now omit unsupported properties, fixing tuning failures.
* `fcst.mase`, `fcst.msis`, and `fcst.rmsse` now infer `period` from `task$freq` unless it is set.
* `PredictionFcst` now stores explicit roles for extra columns in `$col_roles`, replacing type-based detection.
* `rsmp("fcst.holdout", n = 0)` now puts no observations into the training set instead of all of them.
* `TaskFcst` now accepts character or integer keys, while tsibble, tsf, and tsbox converters preserve their types.

# mlr3forecast 0.1.0

* Initial CRAN submission.
