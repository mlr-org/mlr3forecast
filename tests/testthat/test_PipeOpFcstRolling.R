test_that("PipeOpFcstRolling declares fcst_iterative property", {
  expect_subset("fcst_iterative", po("fcst.rolling")$properties)
})

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

test_that("PipeOpFcstRolling aligns train features on date-major keyed task", {
  task = make_date_major_panel_task()
  out = po("fcst.rolling", funs = "mean", window_sizes = 2L, lag = 1L)$train(list(task))[[1L]]
  res = out$data(cols = c("id", "date", "y", "y_roll_mean_2"))
  setorderv(res, c("id", "date"))
  res[, expected := frollmean(shift(y), 2L), by = id]
  expect_equal(res$y_roll_mean_2, res$expected)
})

test_that("PipeOpFcstRolling supports expanding windows via Inf", {
  task = tsk("airpassengers")
  out = po("fcst.rolling", funs = "mean", window_sizes = Inf, lag = 1L)$train(list(task))[[1L]]
  expect_subset("passengers_roll_mean_expanding", out$feature_names)

  y = task$truth()
  expected = vapply(seq_along(y), function(t) if (t == 1L) NA_real_ else mean(y[seq_len(t - 1L)]), numeric(1L))
  expect_equal(out$data(cols = "passengers_roll_mean_expanding")[[1L]], expected)
})

test_that("PipeOpFcstRolling mixes finite and expanding windows", {
  task = tsk("airpassengers")
  out = po("fcst.rolling", funs = c("mean", "sd"), window_sizes = c(3L, Inf))$train(list(task))[[1L]]
  expected = c(
    "passengers_roll_mean_3",
    "passengers_roll_sd_3",
    "passengers_roll_mean_expanding",
    "passengers_roll_sd_expanding"
  )
  expect_subset(expected, out$feature_names)
})

test_that("PipeOpFcstRolling rejects non-integer finite window sizes", {
  expect_snapshot(po("fcst.rolling", window_sizes = 2.5), error = TRUE)
})
