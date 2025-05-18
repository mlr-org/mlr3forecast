skip_if_not_installed("smooth")

test_that("autotest", {
  learner = lrn("fcst.adam")
  expect_learner(learner)
})
