skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.tslm")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("tslm handles exogenous features", {
  withr::local_seed(1)
  dt = data.table(time = 1:48, y = as.numeric(1:48) + rnorm(48), x = rnorm(48))
  task = as_task_fcst(dt, target = "y", order = "time", freq = 12L)
  learner = lrn("fcst.tslm")
  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  expect_subset("x", names(stats::coef(learner$model)))
  p = learner$predict(task, split$test)
  expect_prediction(p)
  expect_false(anyMissing(p$response))
})

test_that("tslm accepts a user formula referencing the target name", {
  withr::local_seed(1)
  dt = data.table(time = 1:48, passengers = as.numeric(1:48) + rnorm(48), x = rnorm(48))
  task = as_task_fcst(dt, target = "passengers", order = "time", freq = 12L)
  learner = lrn("fcst.tslm")
  learner$param_set$set_values(formula = passengers ~ trend + season + x)
  learner$train(task)
  expect_subset("x", names(stats::coef(learner$model)))
})

test_that("tslm does not collide with a feature named the same as the placeholder", {
  withr::local_seed(1)
  dt = data.table(time = 1:48, passengers = as.numeric(1:48) + rnorm(48), y = rnorm(48))
  task = as_task_fcst(dt, target = "passengers", order = "time", freq = 12L)
  learner = lrn("fcst.tslm")
  learner$train(task)
  expect_subset("y", names(stats::coef(learner$model)))
})
