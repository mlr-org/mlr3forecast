skip_if_not_installed("nnfor")

test_that("autotest", {
  learner = lrn("fcst.elm")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("elm uses exogenous features", {
  skip_if_not_installed("withr")

  withr::local_seed(1L)
  dt = data.table(time = 1:72, x = rnorm(72L))
  set(dt, j = "y", value = 10 + 5 * dt$x + rnorm(72L, sd = 0.1))
  task = as_task_fcst(dt, target = "y", order = "time", freq = 12L)
  learner = lrn("fcst.elm", reps = 1L, xreg.lags = list(0L), sel.lag = FALSE)
  learner$train(task, 1:60)
  pred = learner$predict(task, 61:72)
  expect_gt(cor(pred$response, dt$x[61:72]), 0.9)
})
