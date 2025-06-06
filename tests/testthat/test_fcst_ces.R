skip_if_not_installed("smooth")

test_that("autotest", {
  learner = lrn("fcst.ces")
  expect_learner(learner)
  result = run_autotest(learner, exclude = "sanity")
  expect_true(result, info = result$error)
})
