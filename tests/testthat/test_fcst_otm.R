skip_if_not_installed("forecTheta")

test_that("autotest", {
  learner = lrn("fcst.otm")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.otm")
  exclude = c("y", "h", "level", "estimation", "xreg", "s")
  expect_true(run_paramtest(learner, forecTheta::otm, tag = "train", exclude = exclude))
})
