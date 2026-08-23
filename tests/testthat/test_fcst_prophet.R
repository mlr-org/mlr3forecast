skip_if_not_installed("prophet")

test_that("autotest", {
  learner = lrn("fcst.prophet")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("logistic growth uses cap and floor features", {
  withr::local_seed(1L)
  dt = data.table(
    month = seq(as.Date("2020-01-01"), by = "month", length.out = 48L),
    y = 100 / (1 + exp(-seq(-3, 3, length.out = 48L))),
    cap = 100,
    floor = 0,
    x = rnorm(48L)
  )
  task = as_task_fcst(dt, target = "y", order = "month", freq = "month")
  split = partition(task, ratio = 0.8)
  learner = lrn(
    "fcst.prophet",
    growth = "logistic",
    yearly.seasonality = FALSE,
    weekly.seasonality = FALSE,
    daily.seasonality = FALSE,
    uncertainty.samples = 0L
  )
  learner$train(task, split$train)
  expect_setequal(names(learner$native_model$extra_regressors), "x")
  expect_numeric(learner$predict(task, split$test)$response, any.missing = FALSE, len = length(split$test))

  task_without_cap = as_task_fcst(dt[, !"cap"], target = "y", order = "month", freq = "month")
  expect_error(learner$clone(deep = TRUE)$train(task_without_cap), "requires a task feature")
})
