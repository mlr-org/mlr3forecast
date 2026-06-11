skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.holt_winters")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("in-sample prediction returns one-step fitted values", {
  task = tsk("airpassengers")
  learner = lrn("fcst.holt_winters")
  learner$train(task)
  pred = learner$predict(task, 13:144)
  expect_equal(pred$response, as.numeric(learner$model$fitted[, "xhat"]))
  # no fitted values exist before the first complete seasonal cycle
  pred = learner$predict(task)
  expect_equal(pred$response[1:12], rep(NA_real_, 12L))
})
