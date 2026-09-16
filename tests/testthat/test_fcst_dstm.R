skip_if_not_installed("forecTheta")

test_that("autotest", {
  learner = lrn("fcst.dstm")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.dstm")
  exclude = c("y", "h", "level", "estimation", "xreg", "s")
  expect_true(run_paramtest(learner, forecTheta::dstm, tag = "train", exclude = exclude))
})
