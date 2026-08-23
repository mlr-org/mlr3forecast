# mlr3forecast (development version)

* BREAKING CHANGE: Key columns are no longer features by default. Restore the feature role explicitly when needed.
* BREAKING CHANGE: `po("fcstavg")` was renamed to `po("fcst.avg")` to match the id prefix of the other PipeOps.
* feat: `DirectForecaster` gained `$importance()`, `$selected_features()`, and `$oob_error()` methods returning one result per horizon model, named like `$native_model`.
* feat: New learner `fcst.ar` wrapping `stats::ar()`, fitting autoregressive models by Yule-Walker, Burg, OLS, or maximum likelihood with optional AIC order selection.
* feat: `fcst.mean` gained the `bootstrap` and `npaths` parameters for empirical quantiles resampled from the residuals.
* feat: New learner `fcst.sparma` wrapping `smooth::sparma()`, fitting sparse ARMA models whose `orders` map to specific lags instead of expanding polynomials.
* feat: `PredictionFcst` now stores explicit roles for extra columns in `$col_roles`, replacing type-based detection (#52).
* feat: `RecursiveForecaster` now supports validation and internal tuning (configure with `set_validate()`) and delegates `$importance()`, `$selected_features()`, and `$oob_error()` to the wrapped graph.
* feat: `TaskFcst` now accepts character or integer keys, while tsibble, tsf, and tsbox converters preserve their types.
* fix: Numeric `freq` values now represent the seasonal period, while the grid step is inferred from the order column.
* fix: Both forecasters no longer advertise learner properties they cannot honour, fixing failures when tuning with `AutoTuner`. This drops the hotstart properties for both and additionally validation, internal tuning, importance, selected features, and OOB error for `DirectForecaster`.
* fix: `DirectForecaster` now rejects empty or duplicate `horizons` values.
* fix: `fcst.mase`, `fcst.msis`, and `fcst.rmsse` now infer `period` from `task$freq` unless it is set.
* fix: `fcst.nnetar` now supports quantile predictions and uses `bootstrap`, `npaths`, and `innov` when simulating their prediction intervals.
* fix: `PipeOpFcstAvg` now declares its required packages and the `"fcst"` tag instead of dropping them.
* fix: `rsmp("fcst.holdout", n = 0)` now puts no observations into the training set instead of all of them.

# mlr3forecast 0.1.0

* Initial CRAN submission.
