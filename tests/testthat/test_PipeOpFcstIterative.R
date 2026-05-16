test_that("built-in iterative PipeOps inherit from PipeOpFcstIterative", {
  expect_class(po("fcst.lags"), "PipeOpFcstIterative")
  expect_class(po("fcst.rolling"), "PipeOpFcstIterative")
})

test_that("iterative PipeOps compute predict features from full backend", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  p = po("fcst.lags", lags = 1:2)
  p$train(list(task$clone()$filter(split$train)))

  test_task = task$clone()$filter(split$test)
  out = p$predict(list(test_task))[[1L]]
  lag_cols = sprintf("%s_lag_%i", task$target_names, 1:2)
  expect_true(all(lag_cols %in% out$feature_names))
  expect_false(anyNA(out$data(cols = lag_cols)))
})
