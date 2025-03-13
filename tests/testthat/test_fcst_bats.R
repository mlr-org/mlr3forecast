skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.bats")
  expect_learner(learner)
})
