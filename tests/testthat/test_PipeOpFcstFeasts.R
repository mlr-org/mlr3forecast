test_that("PipeOpFcstFeasts adds features to an unkeyed task", {
  skip_if_not_installed("feasts")
  task = tsk("airpassengers")
  po = po("fcst.feasts", features = list(feasts::feat_acf))

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_gt(length(new_feats), 0L)
  expect_all_true(startsWith(new_feats, "passengers_feasts_"))
  expect_identical(out$nrow, task$nrow)
  expect_shape(unique(out$data(cols = new_feats)), nrow = 1L)
})

test_that("PipeOpFcstFeasts broadcasts per-key for keyed tasks", {
  skip_if_not_installed("feasts")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  po = po("fcst.feasts", features = list(feasts::feat_acf))

  out = po$train(list(task))[[1L]]
  new_feats = setdiff(out$feature_names, task$feature_names)
  expect_gt(length(new_feats), 0L)
  expect_identical(out$nrow, task$nrow)

  n_keys = uniqueN(task$data(cols = task$col_roles$key))
  expect_shape(unique(out$data(cols = new_feats)), nrow = n_keys)
})

test_that("PipeOpFcstFeasts predict reuses cached features", {
  skip_if_not_installed("feasts")
  task = tsk("airpassengers")
  po = po("fcst.feasts", features = list(feasts::feat_acf))

  po$train(list(task))
  out = po$predict(list(task))[[1L]]
  expect_subset("passengers_feasts_acf1", out$feature_names)
  expect_identical(out$nrow, task$nrow)
})

test_that("PipeOpFcstFeasts infers seasonal period from monthly order", {
  skip_if_not_installed("feasts")
  task = tsk("airpassengers")
  out = po("fcst.feasts", features = list(feasts::feat_stl))$train(list(task))[[1L]]
  # yearly seasonal feature only appears when the monthly index yields period 12
  expect_subset("passengers_feasts_seasonal_strength_year", out$feature_names)
})
