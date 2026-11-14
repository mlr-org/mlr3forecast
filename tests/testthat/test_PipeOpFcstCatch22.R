test_that("PipeOpFcstCatch22 adds features to an unkeyed task", {
  skip_if_not_installed("Rcatch22")
  task = tsk("airpassengers")
  po = po("fcst.catch22")

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_length(new_feats, 22L)
  expect_all_true(startsWith(new_feats, "passengers_catch22_"))
  expect_identical(out$nrow, task$nrow)
  expect_shape(unique(out$data(cols = new_feats)), nrow = 1L)
})

test_that("PipeOpFcstCatch22 catch24 adds mean and sd", {
  skip_if_not_installed("Rcatch22")
  task = tsk("airpassengers")
  out = po("fcst.catch22", catch24 = TRUE)$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_length(new_feats, 24L)
  expect_subset(c("passengers_catch22_DN_Mean", "passengers_catch22_DN_Spread_Std"), new_feats)
})

test_that("PipeOpFcstCatch22 broadcasts per-key for keyed tasks", {
  skip_if_not_installed("Rcatch22")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  po = po("fcst.catch22")

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_gt(length(new_feats), 0L)
  expect_identical(out$nrow, task$nrow)

  n_keys = uniqueN(task$data(cols = task$col_roles$key))
  expect_shape(unique(out$data(cols = new_feats)), nrow = n_keys)
})

test_that("PipeOpFcstCatch22 predict reuses cached features", {
  skip_if_not_installed("Rcatch22")
  task = tsk("airpassengers")
  po = po("fcst.catch22")

  po$train(list(task))
  out = po$predict(list(task))[[1L]]
  expect_subset("passengers_catch22_CO_f1ecac", out$feature_names)
  expect_identical(out$nrow, task$nrow)
})

test_that("PipeOpFcstCatch22 is not confused by columns named like its variables", {
  skip_if_not_installed("Rcatch22")
  feats = function(task) po("fcst.catch22")$train(list(task))[[1L]]$data()
  expected = feats(make_named_task())
  expect_same_values(feats(make_named_task(target = "target")), expected)
  expect_same_values(feats(make_named_task(key = "catch24")), expected)
  expect_same_values(feats(make_named_task(key = "private")), expected)
})
