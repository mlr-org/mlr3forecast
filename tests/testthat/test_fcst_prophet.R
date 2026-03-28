skip_if_not_installed("prophet")

test_that("autotest", {
  learner = lrn("fcst.prophet")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})
