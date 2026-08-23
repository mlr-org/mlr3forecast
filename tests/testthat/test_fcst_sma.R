skip_if_not_installed("smooth")

test_that("autotest", {
  learner = lrn("fcst.sma")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("training uses the full task", {
  learner = lrn("fcst.sma", order = 3L)
  expect_false("holdout" %in% learner$param_set$ids())
  task = tsk("airpassengers")
  learner$train(task)
  expect_length(learner$native_model$fitted, task$nrow)
  expect_identical(learner$native_model$call$h, 0L)
  expect_numeric(learner$predict(task)$response, any.missing = FALSE, len = task$nrow)
  expect_numeric(forecast(learner, task, h = 10L)$response, any.missing = FALSE, len = 10L)
})
