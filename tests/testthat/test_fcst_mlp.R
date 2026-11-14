skip_if_not_installed("nnfor")

test_that("autotest", {
  learner = lrn("fcst.mlp")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.mlp")
  exclude = c("y", "outplot", "xreg", "model", "period")
  expect_true(run_paramtest(learner, nnfor::mlp, tag = "train", exclude = exclude))
})

test_that("mlp uses exogenous features", {
  skip_if_not_installed("withr")

  withr::local_seed(1L)
  dt = data.table(time = 1:72, x = rnorm(72L))
  set(dt, j = "y", value = 10 + 5 * dt$x + rnorm(72L, sd = 0.1))
  task = as_task_fcst(dt, target = "y", order = "time")
  learner = lrn("fcst.mlp", reps = 1L, hd = 2L, xreg.lags = list(0L), sel.lag = FALSE)
  learner$train(task, 1:60)
  pred = learner$predict(task, 61:72)
  expect_gt(cor(pred$response, dt$x[61:72]), 0.9)
})

test_that("mlp trains with the torch backend", {
  skip_if_not_installed("torch")
  task = tsk("airpassengers")
  learner = lrn("fcst.mlp", reps = 1L, hd = 2L, backend = "torch")$train(task, 1:132)
  expect_identical(learner$native_model$backend, "torch")
  pred = learner$predict(task, 133:144)
  expect_numeric(pred$response, any.missing = FALSE, len = 12L)
})
