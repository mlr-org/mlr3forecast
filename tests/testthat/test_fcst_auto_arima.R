skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.auto_arima")
  expect_learner(learner)
})
