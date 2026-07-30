# mlr3forecast (development version)

* BREAKING CHANGE: key columns are no longer features by default. Add the feature role back explicitly with
  `task$set_col_roles(key, add_to = "feature")` to let a global model specialize per series.
* fix: `rsmp("fcst.holdout", n = 0)` now puts no observations into the training set instead of all of them.

# mlr3forecast 0.1.0

* Initial CRAN submission.
