skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.arfima")
  expect_learner(learner)
  result = run_autotest(learner, exclude = "sanity")
  expect_true(result, info = result$error)
})
