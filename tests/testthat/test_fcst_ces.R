skip_if_not_installed("smooth")

test_that("autotest", {
  learner = lrn("fcst.ces")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})
