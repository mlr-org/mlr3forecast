test_that("PipeOpFcstFourier is not iterative", {
  expect_disjunct("fcst_iterative", po("fcst.fourier")$properties)
})

test_that("PipeOpFcstFourier basic train/predict on airpassengers", {
  task = tsk("airpassengers")
  po = po("fcst.fourier", period = 12, K = 3L)

  out = po$train(list(task))[[1L]]
  expected = c("S1_12", "C1_12", "S2_12", "C2_12", "S3_12", "C3_12")
  expect_subset(expected, out$feature_names)
  expect_equal(out$nrow, task$nrow)

  pred = po$predict(list(task))[[1L]]
  expect_subset(expected, pred$feature_names)
})

test_that("PipeOpFcstFourier matches forecast::fourier", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  out = po("fcst.fourier", period = 12, K = 3L)$train(list(task))[[1L]]
  ours = as.matrix(out$data(cols = c("S1_12", "C1_12", "S2_12", "C2_12", "S3_12", "C3_12")))
  ref = forecast::fourier(stats::ts(task$truth(), frequency = 12), K = 3)
  expect_equal(apply(ours, 1L, sort), apply(ref, 1L, sort))
})

test_that("PipeOpFcstFourier drops identically-zero sine terms", {
  out = po("fcst.fourier", period = 12, K = 6L)$train(list(tsk("airpassengers")))[[1L]]
  expect_subset("C6_12", out$feature_names)
  expect_disjunct("S6_12", out$feature_names)
})

test_that("PipeOpFcstFourier derives period from task frequency", {
  out = po("fcst.fourier", K = 2L)$train(list(tsk("airpassengers")))[[1L]]
  expect_subset(c("S1_12", "C1_12", "S2_12", "C2_12"), out$feature_names)
})

test_that("PipeOpFcstFourier supports multiple seasonalities", {
  out = po("fcst.fourier", period = c(7, 12), K = c(2L, 3L))$train(list(tsk("airpassengers")))[[1L]]
  expect_subset(c("S1_7", "C1_7", "S1_12", "C3_12"), out$feature_names)
})

test_that("PipeOpFcstFourier deduplicates overlapping harmonics", {
  out = po("fcst.fourier", period = c(4, 12), K = c(2L, 3L))$train(list(tsk("airpassengers")))[[1L]]
  expect_disjunct(c("S3_12", "C3_12"), out$feature_names)
})

test_that("PipeOpFcstFourier errors when K exceeds period/2", {
  expect_snapshot(po("fcst.fourier", period = 4, K = 3L)$train(list(tsk("airpassengers"))), error = TRUE)
})

test_that("PipeOpFcstFourier keeps phase across train/predict split", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  po = po("fcst.fourier", period = 12, K = 2L)
  po$train(list(task$clone()$filter(split$train)))
  pred = po$predict(list(task$clone()$filter(split$test)))[[1L]]
  ours = as.matrix(pred$data(cols = c("S1_12", "C1_12", "S2_12", "C2_12")))
  ref = forecast::fourier(stats::ts(task$truth()[split$train], frequency = 12), K = 2, h = length(split$test))
  expect_equal(apply(ours, 1L, sort), apply(ref, 1L, sort))
})

test_that("PipeOpFcstFourier works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  out = po("fcst.fourier", period = 12, K = 2L)$train(list(task))[[1L]]
  expect_true(any(grepl("^S1_12$", out$feature_names)))
  expect_equal(out$nrow, task$nrow)
})
