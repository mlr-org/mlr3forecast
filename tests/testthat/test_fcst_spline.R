skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.spline")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})
