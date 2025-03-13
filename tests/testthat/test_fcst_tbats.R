skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.tbats")
  expect_learner(learner)
})
