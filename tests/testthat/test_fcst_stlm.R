skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.stlm")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("stlm uses exogenous features with method = 'arima'", {
  withr::local_seed(1)
  dt = data.table(time = 1:60, y = as.numeric(1:60) + rnorm(60), x = rnorm(60))
  task = as_task_fcst(dt, target = "y", order = "time", freq = 12L)
  split = partition(task, ratio = 0.8)
  learner = lrn("fcst.stlm", method = "arima")
  learner$train(task, split$train)
  p = learner$predict(task, split$test)
  expect_numeric(p$response, any.missing = FALSE, len = length(split$test))
})

test_that("stlm errors clearly when features are used without method = 'arima'", {
  withr::local_seed(1)
  dt = data.table(time = 1:60, y = as.numeric(1:60) + rnorm(60), x = rnorm(60))
  task = as_task_fcst(dt, target = "y", order = "time", freq = 12L)
  learner = lrn("fcst.stlm")
  expect_snapshot(learner$train(task), error = TRUE)
})
