test_that("PipeOpFcstRolling basic train/predict on airpassengers", {
  task = tsk("airpassengers")
  po = po("fcst.rolling", funs = c("mean", "sd"), window_sizes = c(3L, 12L), lag = 1L)

  out = po$train(list(task))[[1L]]
  expected = c("passengers_roll_mean_3", "passengers_roll_mean_12", "passengers_roll_sd_3", "passengers_roll_sd_12")
  expect_true(all(expected %in% out$feature_names))
  expect_equal(out$nrow, task$nrow)

  pred = po$predict(list(task))[[1L]]
  expect_true(all(expected %in% pred$feature_names))
})

test_that("PipeOpFcstRolling works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  po = po("fcst.rolling", funs = "mean", window_sizes = 3L)

  out = po$train(list(task))[[1L]]
  expect_true(any(grepl("_roll_mean_3$", out$feature_names)))
  expect_equal(out$nrow, task$nrow)
})

