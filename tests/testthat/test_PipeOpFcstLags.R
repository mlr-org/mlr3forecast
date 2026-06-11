test_that("PipeOpFcstLags declares fcst_iterative property", {
  expect_subset("fcst_iterative", po("fcst.lags")$properties)
})

test_that("PipeOpFcstLags rejects non-positive lags", {
  expect_snapshot(po("fcst.lags", lags = 0L), error = TRUE)
  expect_snapshot(po("fcst.lags", lags = c(1L, -1L)), error = TRUE)
})

test_that("PipeOpFcstLags computes predict features from full backend", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  p = po("fcst.lags", lags = 1:2)
  p$train(list(task$clone()$filter(split$train)))

  test_task = task$clone()$filter(split$test)
  out = p$predict(list(test_task))[[1L]]
  lag_cols = sprintf("%s_lag_%i", task$target_names, 1:2)
  expect_subset(lag_cols, out$feature_names)
  expect_false(anyNA(out$data(cols = lag_cols)))
})
