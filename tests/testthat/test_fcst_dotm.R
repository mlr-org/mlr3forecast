skip_if_not_installed("forecTheta")

test_that("autotest", {
  learner = lrn("fcst.dotm")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.dotm")
  exclude = c("y", "h", "level", "estimation", "xreg", "s", "period")
  expect_true(run_paramtest(learner, forecTheta::dotm, tag = "train", exclude = exclude))
})

test_that("the period hyperparameter sets the ts frequency", {
  task = tsk("airpassengers")
  learner = lrn("fcst.dotm", period = 4)$train(task)
  expect_equal(stats::frequency(learner$native_model$y), 4)
})
