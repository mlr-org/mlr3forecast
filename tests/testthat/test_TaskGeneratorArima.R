test_that("arima generator", {
  generator = tgen("arima")
  expect_identical(
    generator$param_set$values,
    list(ar = 0.7, d = 0L, ma = numeric(), sd = 1, k = 1L, freq = "month", start = as.Date("2000-01-01"))
  )
  task = generator$generate(24L)
  expect_identical(task$feature_names, character())
  expect_identical(task$data(cols = "date")[[1L]], seq(as.Date("2000-01-01"), by = "month", length.out = 24L))
  expect_numeric(task$truth(), len = 24L, any.missing = FALSE)
})

test_that("arima generator builds keyed panels", {
  task = tgen("arima", k = 3L)$generate(10L)
  expect_identical(task$nrow, 30L)
  expect_identical(task$col_roles$key, "series")
  expect_factor(task$data(cols = "series")[[1L]], levels = c("1", "2", "3"))
  expect_identical(task$data(cols = "series")[, .N, by = "series"]$N, rep(10L, 3L))
})

test_that("arima generator handles differencing and integer index", {
  withr::local_seed(1L)
  task = tgen("arima", ar = numeric(), d = 1L, freq = 4)$generate(20L)
  expect_identical(task$nrow, 20L)
  expect_identical(task$col_roles$order, "index")
  expect_identical(task$data(cols = "index")[[1L]], 1:20)
  expect_identical(task$freq, 4)
  expect_error(tgen("arima", ar = 1.5)$generate(10L), "not stationary")
})

test_that("arima generator supports sub-daily frequencies", {
  task = tgen("arima", freq = "hour", start = as.Date("2020-01-01"))$generate(5L)
  expect_posixct(task$data(cols = "date")[[1L]], len = 5L)
})

test_that("arima generator is reproducible", {
  generator = tgen("arima", ma = 0.3, k = 2L)
  task1 = withr::with_seed(1L, generator$generate(40L))
  task2 = withr::with_seed(1L, generator$generate(40L))
  expect_identical(task1$data(), task2$data())
})
