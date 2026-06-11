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

test_that("infer_freq preserves non-unit spacing", {
  step = function(secs) {
    t = as.POSIXct("2020-01-01", tz = "UTC") + seq(0, length.out = 5L, by = secs)
    f = infer_freq(t)
    as.numeric(diff(seq(t[5L], length.out = 2L, by = f)), units = "secs")
  }
  expect_equal(step(4), 4)
  expect_equal(step(90), 90)
  expect_equal(step(600), 600)
  expect_equal(step(900), 900)
  expect_equal(step(1800), 1800)
  expect_equal(step(3600), 3600)
  expect_equal(step(5400), 5400)
  expect_equal(step(172800), 172800)
  expect_equal(step(1209600), 1209600)
  expect_equal(step(2592000), 2592000) # fixed 30-day, not calendar month
})

test_that("infer_freq detects calendar units", {
  expect_equal(infer_freq(seq(as.Date("2020-01-01"), by = "week", length.out = 10L)), "week")
  expect_equal(infer_freq(seq(as.Date("2020-01-01"), by = "month", length.out = 24L)), "1 month")
  expect_equal(infer_freq(seq(as.Date("2020-01-01"), by = "2 month", length.out = 12L)), "2 month")
  expect_equal(infer_freq(seq(as.Date("2020-01-01"), by = "quarter", length.out = 12L)), "quarter")
  expect_equal(infer_freq(seq(as.Date("2020-01-01"), by = "6 month", length.out = 10L)), "6 month")
  expect_equal(infer_freq(seq(as.Date("2000-01-01"), by = "year", length.out = 10L)), "year")
  month_end = as.Date(c("2020-01-31", "2020-02-29", "2020-03-31", "2020-04-30", "2020-05-31"))
  expect_equal(infer_freq(month_end), "month")
})

test_that("quantiles_to_level dedupes floating-point levels", {
  expect_equal(quantiles_to_level(c(0.05, 0.1, 0.9, 0.95)), c(80, 90))
  expect_equal(quantiles_to_level(c(0.05, 0.5, 0.95)), 90)
})

test_that("as.ts works", {
  task = tsk("airpassengers")
  ts = as.ts(task)
  expect_class(ts, "ts")
  expect_length(ts, task$nrow)
  expect_identical(stats::frequency(ts), 12)
})

test_that("as.ts works with explicit freq", {
  task = tsk("airpassengers")
  ts = as.ts(task, freq = 4L)
  expect_class(ts, "ts")
  expect_identical(stats::frequency(ts), 4)
})
