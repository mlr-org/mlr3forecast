skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.arima")
  expect_learner(learner)
})
