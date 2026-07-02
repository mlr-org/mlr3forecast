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

test_that("a tsf with frequency but no timestamp uses an integer step", {
  file = withr::local_tempfile(fileext = ".tsf")
  writeLines(c("@attribute series_name string", "@frequency yearly", "@data", "T1:10,20,30,40"), file)
  task = as_task_fcst(read_tsf(file))
  # without a real timestamp the calendar frequency must not be carried over, else seq_order would
  # do date arithmetic on the bare integer index (giving e.g. 365, 730, 1096 instead of 5, 6, 7)
  expect_null(task$freq)
  newdata = generate_newdata(task, n = 3L)
  expect_equal(as.numeric(newdata[[task$col_roles$order]]), c(5, 6, 7))
})

test_that("generate_newdata works with Date order", {
  task = tsk("airpassengers")
  newdata = generate_newdata(task, n = 3L)
  expect_data_table(newdata, nrows = 3L)
  expect_class(newdata$month, "Date")
  # dates should be sequential
  expect_true(all(diff(newdata$month) > 0L))
})

test_that("generate_newdata clamps day-of-month without overflow", {
  month_end = as.Date(c("2020-01-31", "2020-02-29", "2020-03-31", "2020-04-30"))
  task = as_task_fcst(data.table(month = month_end, y = 1:4), target = "y", order = "month", freq = "month")
  newdata = generate_newdata(task, n = 3L)
  # origin Apr-30 is carried forward on the 30th (no eom snap, no month overflow)
  expect_identical(newdata$month, as.Date(c("2020-05-30", "2020-06-30", "2020-07-30")))
})

test_that("generate_newdata preserves mid-month day-of-month", {
  mid = seq(as.Date("2020-01-15"), by = "month", length.out = 4L)
  task = as_task_fcst(data.table(month = mid, y = 1:4), target = "y", order = "month", freq = "month")
  newdata = generate_newdata(task, n = 3L)
  expect_identical(newdata$month, as.Date(c("2020-05-15", "2020-06-15", "2020-07-15")))
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
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  pred = forecast(flrn, task, h = 12L)
  expect_class(pred, "PredictionRegr")
  expect_length(pred$response, 12L)
})

test_that("forecast() works with DirectForecaster", {
  task = tsk("airpassengers")
  flrn = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = 6L)
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
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
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
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  newdata = CJ(date = seq(as.Date("2026-01-01"), by = "month", length.out = 3L), id = factor(c("a", "b")))
  set(newdata, j = "temp", value = 100)
  set(newdata, j = "press", value = 900)
  pred = forecast(flrn, task, h = 3L, newdata = newdata)
  expect_length(pred$response, 6L)
})

test_that("forecast() validates newdata alignment", {
  withr::local_seed(42L)
  dt = data.table(
    date = rep(seq(as.Date("2024-01-01"), by = "month", length.out = 24L), 2L),
    id = factor(rep(c("a", "b"), each = 24L)),
    temp = rnorm(48L, 20),
    value = rnorm(48L)
  )
  task = as_task_fcst(dt, target = "value", order = "date", key = "id", freq = "month")
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  # key columns alone must not silently broadcast across all future rows
  newdata = data.table(id = factor(c("a", "b")), temp = c(100, 200))
  expect_error(forecast(flrn, task, h = 3L, newdata = newdata), "missing 'date'")

  # duplicated (order, key) combinations would make the overlay nondeterministic
  newdata = data.table(date = as.Date("2026-01-01"), id = factor(c("a", "a")), temp = c(100, 200))
  expect_error(forecast(flrn, task, h = 3L, newdata = newdata), "duplicated")

  # rows off the generated future grid must not be silently ignored
  newdata = CJ(date = as.Date(c("2026-01-15", "2026-06-01")), id = factor(c("a", "b")))
  set(newdata, j = "temp", value = 100)
  expect_error(forecast(flrn, task, h = 3L, newdata = newdata), "do not match the generated future grid")

  # a partial overlay covering only some future rows is still allowed
  newdata = data.table(date = as.Date("2026-01-01"), id = factor(c("a", "b")), temp = c(100, 200))
  pred = forecast(flrn, task, h = 3L, newdata = newdata)
  expect_length(pred$response, 6L)
})

test_that("forecast() works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task)

  n_keys = uniqueN(task$data(cols = task$col_roles$key))
  pred = forecast(flrn, task, h = 3L)
  expect_length(pred$response, 3L * n_keys)
})
