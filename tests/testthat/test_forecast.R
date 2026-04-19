test_that("forecast() works with RecursiveForecaster", {
  task = tsk("airpassengers")
  flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  pred = forecast(flrn, task, h = 12L)
  expect_class(pred, "PredictionRegr")
  expect_length(pred$response, 12L)
})

test_that("forecast() works with DirectForecaster", {
  task = tsk("airpassengers")
  flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3, horizons = 6L)
  flrn$train(task)

  pred = forecast(flrn, task, h = 6L)
  expect_class(pred, "PredictionRegr")
  expect_length(pred$response, 6L)
})

test_that("forecast() works with a classic forecast learner", {
  task = tsk("airpassengers")
  flrn = lrn("fcst.mean")
  flrn$train(task)

  pred = forecast(flrn, task, h = 12L)
  expect_class(pred, "PredictionRegr")
  expect_length(pred$response, 12L)
})

test_that("forecast() overlays newdata onto the skeleton", {
  task = tsk("airpassengers")
  flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  last_month = task$data(cols = task$col_roles$order)[.N][[1L]]
  newdata = data.table(month = seq(last_month, length.out = 7L, by = "month")[-1L])
  pred = forecast(flrn, task, h = 6L, newdata = newdata)
  expect_length(pred$response, 6L)
})

test_that("forecast() works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  n_keys = uniqueN(task$data(cols = task$col_roles$key))
  pred = forecast(flrn, task, h = 3L)
  expect_length(pred$response, 3L * n_keys)
})
