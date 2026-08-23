test_that("forecast task type has a default measure", {
  expect_equal(default_measures("fcst")[[1L]]$id, "regr.mse")
})

test_that("forecast resampling aggregates with the default measure", {
  skip_if_not_installed("forecast")
  rr = resample(tsk("airpassengers"), lrn("fcst.mean"), rsmp("fcst.holdout", ratio = 0.8))
  expect_number(rr$aggregate(), lower = 0, finite = TRUE)
})
