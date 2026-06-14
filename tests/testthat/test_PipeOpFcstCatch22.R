test_that("PipeOpFcstCatch22 adds features to an unkeyed task", {
  skip_if_not_installed("Rcatch22")
  task = tsk("airpassengers")
  po = po("fcst.catch22")

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_equal(length(new_feats), 22L)
  expect_true(all(startsWith(new_feats, "passengers_catch22_")))
  expect_equal(out$nrow, task$nrow)
  expect_equal(nrow(unique(out$data(cols = new_feats))), 1L)
})

test_that("PipeOpFcstCatch22 catch24 adds mean and sd", {
  skip_if_not_installed("Rcatch22")
  task = tsk("airpassengers")
  out = po("fcst.catch22", catch24 = TRUE)$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_equal(length(new_feats), 24L)
  expect_subset(c("passengers_catch22_DN_Mean", "passengers_catch22_DN_Spread_Std"), new_feats)
})

test_that("PipeOpFcstCatch22 broadcasts per-key for keyed tasks", {
  skip_if_not_installed("Rcatch22")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  po = po("fcst.catch22")

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_true(length(new_feats) > 0L)
  expect_equal(out$nrow, task$nrow)

  n_keys = uniqueN(task$data(cols = task$col_roles$key))
  expect_equal(nrow(unique(out$data(cols = new_feats))), n_keys)
})

test_that("PipeOpFcstCatch22 predict reuses cached features", {
  skip_if_not_installed("Rcatch22")
  task = tsk("airpassengers")
  po = po("fcst.catch22")

  po$train(list(task))
  out = po$predict(list(task))[[1L]]
  expect_true("passengers_catch22_CO_f1ecac" %in% out$feature_names)
  expect_equal(out$nrow, task$nrow)
})
