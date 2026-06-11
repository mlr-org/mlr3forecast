test_that("generate_newdata works", {
  task = tsk("airpassengers")
  newdata = generate_newdata(task)
  expect_data_table(newdata, nrows = 1L)
  expect_names(names(newdata), must.include = c("month", "passengers"))
  expect_true(allMissing(newdata$passengers))

  newdata = generate_newdata(task, n = 5L)
  expect_data_table(newdata, nrows = 5L)
  expect_true(allMissing(newdata$passengers))
})

test_that("generate_newdata works with integer order", {
  dt = data.table(time = 1:10, value = rnorm(10))
  task = as_task_fcst(dt, target = "value", order = "time")
  newdata = generate_newdata(task, n = 3L)
  expect_data_table(newdata, nrows = 3L)
  expect_identical(newdata$time, 11:13)
  expect_true(allMissing(newdata$value))
})

test_that("generate_newdata anchors on the chronologically last row when backend is unsorted", {
  dt = data.table(time = 1:10, value = rnorm(10))[c(6:10, 1:5)]
  task = as_task_fcst(dt, target = "value", order = "time")
  newdata = generate_newdata(task, n = 3L)
  expect_identical(newdata$time, 11:13)
})

test_that("generate_newdata works with Date order", {
  task = tsk("airpassengers")
  newdata = generate_newdata(task, n = 3L)
  expect_data_table(newdata, nrows = 3L)
  expect_class(newdata$month, "Date")
  # dates should be sequential
  expect_true(all(diff(newdata$month) > 0L))
})

test_that("generate_newdata works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  newdata = generate_newdata(task, n = 2L)
  key_cols = task$col_roles$key
  n_keys = uniqueN(task$data(cols = key_cols), by = key_cols)
  expect_data_table(newdata, nrows = 2L * n_keys)
  expect_true(allMissing(newdata[[task$target_names]]))
})

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
  flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3, strategy = "direct", horizons = 6L)
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

test_that("forecast() overlays multiple exogenous columns on a keyed task", {
  withr::local_seed(42L)
  dt = data.table(
    date = rep(seq(as.Date("2024-01-01"), by = "month", length.out = 24L), 2L),
    id = factor(rep(c("a", "b"), each = 24L)),
    temp = rnorm(48L, 20),
    press = rnorm(48L, 1000),
    value = rnorm(48L)
  )
  task = as_task_fcst(dt, target = "value", order = "date", key = "id", freq = "month")
  flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  newdata = CJ(date = seq(as.Date("2026-01-01"), by = "month", length.out = 3L), id = factor(c("a", "b")))
  set(newdata, j = "temp", value = 100)
  set(newdata, j = "press", value = 900)
  pred = forecast(flrn, task, h = 3L, newdata = newdata)
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
