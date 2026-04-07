skip_if_not_installed("tscount")

test_that("autotest", {
  learner = lrn("fcst.tscount")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})
