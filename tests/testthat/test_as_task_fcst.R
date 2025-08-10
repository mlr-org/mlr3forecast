test_that("as_task conversion", {
  skip_if_not_installed("zoo")
  skip_if_not_installed("xts")

  # ts object
  expect_no_error(as_task_fcst(AirPassengers))
  # mts object
  expect_no_error(as_task_fcst(EuStockMarkets))
  # zoo object
  expect_no_error(as_task_fcst(zoo::zoo(rnorm(50L), seq(as.Date("2020-01-01"), by = "month", length.out = 50L))))
  # xts object
  expect_no_error(as_task_fcst(xts::xts(rnorm(100L), seq(as.Date("2020-01-01"), by = "day", length.out = 100L))))
})

test_that("as_task_fcst assertions", {
  # unique order values
  expect_error(
    as_task_fcst(
      data.table(date = rep(seq(as.Date("2025-01-01"), length.out = 10L), 2), value = rnorm(20L)),
      target = "value",
      order = "date"
    ),
    "`order` values must be unique for each time series."
  )
  # with key col
  expect_no_error(as_task_fcst(
    data.table(
      date = rep(seq(as.Date("2025-01-01"), length.out = 10L), 2),
      value = rnorm(20L),
      id = rep(c("a", "b"), each = 10L)
    ),
    target = "value",
    order = "date",
    key = "id"
  ))
  # with key col
  expect_error(
    as_task_fcst(
      data.table(
        date = rep(seq(as.Date("2025-01-01"), length.out = 10L), 2),
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
