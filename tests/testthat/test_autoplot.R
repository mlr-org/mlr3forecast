test_that("autoplot.TaskFcst works", {
  skip_if_not_installed("vdiffr")

  task = tsk("airpassengers")
  p = autoplot(task)
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("taskfcst_default", p)
})

test_that("autoplot.TaskFcst works with custom theme", {
  skip_if_not_installed("vdiffr")

  task = tsk("airpassengers")
  p = autoplot(task, theme = ggplot2::theme_bw())
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("taskfcst_theme_bw", p)
})

test_that("autoplot.PredictionRegr works", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("forecast")

  task = tsk("airpassengers")
  split = partition(task)
  lrn = lrn("fcst.auto_arima")
  lrn$train(task, split$train)
  pred = lrn$predict(task, split$test)

  p = autoplot(pred)
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("prediction_default", p)

  p = autoplot(pred, task, split$train)
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("prediction_with_context", p)
})

test_that("autoplot.PredictionRegr works with quantiles", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("forecast")

  task = tsk("airpassengers")
  split = partition(task)
  lrn = lrn("fcst.auto_arima", predict_type = "quantiles", quantiles = c(0.025, 0.5, 0.975), quantile_response = 0.5)
  lrn$train(task, split$train)
  pred = lrn$predict(task, split$test)

  p = autoplot(pred, task, split$train)
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("prediction_quantiles", p)
})
