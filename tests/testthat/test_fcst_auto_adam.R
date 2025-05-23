skip_if_not_installed("smooth")

test_that("autotest", {
  learner = lrn("fcst.auto_adam")
  expect_learner(learner)
  result = run_autotest(learner, exclude = "sanity")
  expect_true(result, info = result$error)
})
