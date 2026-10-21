test_that("as_task conversion", {
  skip_if_not_installed("zoo")
  skip_if_not_installed("xts")

  # data.frame
  df = data.frame(
    date = seq(as.Date("1959-01-01"), by = "month", length.out = length(co2)),
    co2 = as.numeric(load_dataset("co2", "datasets"))
  )
  expect_no_error(as_task_fcst(df, target = "co2", order = "date"))
  expect_no_error(as_task_fcst(
    load_dataset("Orange", "datasets"),
    target = "circumference",
    order = "age",
    key = "Tree"
  ))
  # ts object
  expect_no_error(as_task_fcst(load_dataset("AirPassengers", "datasets")))
  # mts object
  expect_no_error(as_task_fcst(load_dataset("EuStockMarkets", "datasets")))
  # zoo object
  expect_no_error(as_task_fcst(zoo::zoo(rnorm(50L), seq(as.Date("2020-01-01"), by = "month", length.out = 50L))))
  x = zoo::zoo(
    matrix(rnorm(150L), ncol = 3L, dimnames = list(NULL, c("x", "y", "z"))),
    seq(as.Date("2020-01-01"), by = "month", length.out = 50L)
  )
  expect_no_error(as_task_fcst(x))
  # xts object
  expect_no_error(as_task_fcst(xts::xts(rnorm(100L), seq(as.Date("2020-01-01"), by = "day", length.out = 100L))))
  x = xts::xts(
    matrix(rnorm(150L), ncol = 3L, dimnames = list(NULL, c("x", "y", "z"))),
    seq(as.Date("2020-01-01"), by = "month", length.out = 50L)
  )
  expect_no_error(as_task_fcst(x))
})

test_that("as_task_fcst warns that a non-calendar ts frequency is not kept", {
  skip_if_not_installed("tsbox")
  expect_warning(
    {
      task = as_task_fcst(ts(sin(1:28), frequency = 7))
    },
    "no calendar step"
  )
  expect_identical(task$freq, 1L)
  expect_identical(task$col_roles$order, "index")
  expect_identical(task$data(cols = "index")$index, 1:28)
  task = suppressWarnings(as_task_fcst(EuStockMarkets))
  expect_identical(task$col_roles$key, "id")
  expect_identical(task$nrow, length(EuStockMarkets))
})

test_that("as_task_fcst keeps the numeric index of a zoo object", {
  skip_if_not_installed("zoo")
  task = as_task_fcst(zoo::zoo(c(1, 2, 3, 4, 5), c(2, 4, 6, 8, 10)))
  expect_identical(task$col_roles$order, "index")
  expect_identical(task$data(cols = "index")$index, c(2, 4, 6, 8, 10))
  expect_identical(task$freq, 2)
  x = zoo::zoo(cbind(a = c(1, 2, 3), b = c(NA, 2, 3)), 1:3)
  task = as_task_fcst(x)
  expect_identical(task$col_roles$key, "id")
  expect_identical(task$nrow, 5L)
})

test_that("as_task_fcst rejects unused arguments for TaskFcst", {
  expect_error(as_task_fcst(tsk("airpassengers"), typo = TRUE), "unused: typo")
})

test_that("as_task_fcst coerces whole-number tsf attributes to integer keys", {
  file = system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast")
  dt = read_tsf(file)
  dt[, horizon := 6]
  setcolorder(dt, "value", after = ncol(dt))
  task = as_task_fcst(dt)
  expect_identical(task$col_roles$key, c("series_name", "horizon"))
  expect_integer(task$data(cols = "horizon")[[1L]])

  dt[, horizon := 6.5]
  expect_error(as_task_fcst(dt), "Key column", class = "Mlr3ErrorInput")
})

test_that("as_task converts tsf objects", {
  file = system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast")
  task = as_task(read_tsf(file), id = "m3_yearly")

  expect_class(task, "TaskFcst")
  expect_identical(task$id, "m3_yearly")

  m3_yearly = read_tsf(file)
  expect_identical(as_task(m3_yearly)$id, "m3_yearly")
  expect_class(as_task(m3_yearly, clone = TRUE), "TaskFcst")
})

test_that("as_task conversion timeSeries", {
  skip_if_not_installed("timeSeries")

  times = seq(as.Date("2020-01-01"), by = "month", length.out = 50L)
  # univariate
  x = timeSeries::timeSeries(rnorm(50L), times)
  expect_no_error(as_task_fcst(x))
  # multivariate
  x = timeSeries::timeSeries(
    matrix(rnorm(150L), ncol = 3L, dimnames = list(NULL, c("x", "y", "z"))),
    times
  )
  expect_no_error(as_task_fcst(x))
})

test_that("as_task conversion keyed tsibble", {
  skip_if_not_installed("tsibble")

  x = tsibble::tsibble(
    id = c("a", "a", "b", "b"),
    time = rep(seq(as.Date("2020-01-01"), by = "day", length.out = 2L), 2L),
    y = 1:4,
    key = id,
    index = time
  )
  task = as_task_fcst(x, target = "y")

  expect_class(task, "TaskFcst")
  expect_equal(task$col_roles$key, "id")
  expect_true("keys" %in% task$properties)
  expect_character(task$data(cols = "id")$id)
})

test_that("as_task conversion multi-measure tsibble", {
  skip_if_not_installed("tsibble")

  dates = seq(as.Date("2020-01-01"), by = "month", length.out = 4L)
  x = tsibble::tsibble(
    month = tsibble::yearmonth(dates),
    y = c(1, 2, 3, 4),
    x1 = c(5, 6, 7, 8),
    flag = c(TRUE, FALSE, TRUE, FALSE),
    index = month
  )
  task = as_task_fcst(x, target = "y")

  expect_identical(task$target_names, "y")
  expect_setequal(task$feature_names, c("x1", "flag"))
  expect_identical(task$data(cols = "month")$month, dates)
  expect_data_table(generate_newdata(task, 2L), nrows = 2L)
})

test_that("as_task conversion tsibble derives freq from a calendar index", {
  skip_if_not_installed("tsibble")

  make = function(index) tsibble::tsibble(t = index, y = seq_along(index), index = t)
  dates = function(by) seq(as.Date("2020-01-06"), by = by, length.out = 4L)
  expect_identical(as_task_fcst(make(tsibble::yearmonth(dates("month"))), target = "y")$freq, "1 month")
  expect_identical(as_task_fcst(make(tsibble::yearquarter(dates("quarter"))), target = "y")$freq, "1 quarter")
  expect_identical(as_task_fcst(make(tsibble::yearweek(dates("2 week"))), target = "y")$freq, "2 week")
  expect_identical(as_task_fcst(make(tsibble::yearmonth(dates("2 month"))), target = "y")$freq, "2 month")
  expect_identical(as_task_fcst(make(tsibble::yearmonth(dates("month"))), target = "y", freq = "month")$freq, "month")
  single = make(tsibble::yearmonth(dates("month")[1L]))
  expect_error(as_task_fcst(single, target = "y"), "at least two")
  expect_identical(as_task_fcst(single, target = "y", freq = "month")$freq, "month")
  expect_identical(as_task_fcst(make(dates("month")), target = "y")$freq, "1 month")

  task = as_task_fcst(tsibble::as_tsibble(AirPassengers), target = "value")
  expect_identical(stats::frequency(as.ts(task)), 12)
})

test_that("as_task conversion tsibble keeps numeric index", {
  skip_if_not_installed("tsibble")

  x = tsibble::tsibble(year = 2000:2003, y = c(1, 2, 3, 4), index = year)
  expect_identical(as_task_fcst(x, target = "y")$data(cols = "year")$year, 2000:2003)
})

test_that("as_task_fcst assertions", {
  # target can't be NA
  value = rnorm(20L)
  value[1:10] = NA
  expect_error(
    as_task_fcst(
      data.table(date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2L), value = value),
      target = "value",
      order = "date"
    ),
    "Target column 'value' must not contain missing values."
  )

  # unique order values
  expect_error(
    as_task_fcst(
      data.table(date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2L), value = rnorm(20L)),
      target = "value",
      order = "date"
    ),
    "`order` values must be unique for each time series."
  )

  # with key col
  expect_no_error(as_task_fcst(
    data.table(
      date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2),
      value = rnorm(20L),
      id = factor(rep(c("a", "b"), each = 10L))
    ),
    target = "value",
    order = "date",
    key = "id"
  ))

  # with key col
  expect_error(
    as_task_fcst(
      data.table(
        date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2),
        value = rnorm(20L),
        id = rep_len("a", 20L)
      ),
      target = "value",
      order = "date",
      key = "id"
    ),
    "`order` values must be unique for each time series."
  )
})
