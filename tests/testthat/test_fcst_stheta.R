skip_if_not_installed("forecTheta")

test_that("autotest", {
  learner = lrn("fcst.stheta")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.stheta")
  expect_true(run_paramtest(learner, forecTheta::stheta, tag = "train", exclude = c("y", "h", "s")))
})
