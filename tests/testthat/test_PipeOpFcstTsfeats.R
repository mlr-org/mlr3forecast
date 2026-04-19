test_that("PipeOpFcstTsfeats adds features to an unkeyed task", {
  skip_if_not_installed("tsfeatures")
  task = tsk("airpassengers")
  po = po("fcst.tsfeats", features = c("entropy", "acf_features"))

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_true(length(new_feats) > 0L)
  expect_true(all(startsWith(new_feats, "passengers_tsf_")))
  expect_equal(out$nrow, task$nrow)
  expect_equal(nrow(unique(out$data(cols = new_feats))), 1L)
})

test_that("PipeOpFcstTsfeats broadcasts per-key for keyed tasks", {
  skip_if_not_installed("tsfeatures")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  po = po("fcst.tsfeats", features = "entropy")

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_true(length(new_feats) > 0L)
  expect_equal(out$nrow, task$nrow)

  n_keys = uniqueN(task$data(cols = task$col_roles$key))
  expect_equal(nrow(unique(out$data(cols = new_feats))), n_keys)
})

test_that("PipeOpFcstTsfeats predict reuses cached features", {
  skip_if_not_installed("tsfeatures")
  task = tsk("airpassengers")
  po = po("fcst.tsfeats", features = "entropy")

  po$train(list(task))
  out = po$predict(list(task))[[1L]]
  expect_true("passengers_tsf_entropy" %in% out$feature_names)
  expect_equal(out$nrow, task$nrow)
})
