test_that("PipeOpFcstTsfeats adds features to an unkeyed task", {
  skip_if_not_installed("tsfeatures")
  task = tsk("airpassengers")
  po = po("fcst.tsfeats", features = c("entropy", "acf_features"))

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_gt(length(new_feats), 0L)
  expect_all_true(startsWith(new_feats, "passengers_tsf_"))
  expect_identical(out$nrow, task$nrow)
  expect_shape(unique(out$data(cols = new_feats)), nrow = 1L)
})

test_that("PipeOpFcstTsfeats broadcasts per-key for keyed tasks", {
  skip_if_not_installed("tsfeatures")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  po = po("fcst.tsfeats", features = "entropy")

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_gt(length(new_feats), 0L)
  expect_identical(out$nrow, task$nrow)

  n_keys = uniqueN(task$data(cols = task$col_roles$key))
  expect_shape(unique(out$data(cols = new_feats)), nrow = n_keys)
})

test_that("PipeOpFcstTsfeats predict reuses cached features", {
  skip_if_not_installed("tsfeatures")
  task = tsk("airpassengers")
  po = po("fcst.tsfeats", features = "entropy")

  po$train(list(task))
  out = po$predict(list(task))[[1L]]
  expect_subset("passengers_tsf_entropy", out$feature_names)
  expect_identical(out$nrow, task$nrow)
})

test_that("PipeOpFcstTsfeats is not confused by columns named like its variables", {
  skip_if_not_installed("tsfeatures")
  feats = function(task) po("fcst.tsfeats", features = "entropy")$train(list(task))[[1L]]$data()
  expected = feats(make_named_task())
  expect_same_values(feats(make_named_task(target = "target")), expected)
  expect_same_values(feats(make_named_task(key = "period")), expected)
})
