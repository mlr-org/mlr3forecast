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
    "`target` must not contain `NA` values."
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
