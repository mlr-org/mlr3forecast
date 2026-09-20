test_that("seasonal generator", {
  generator = tgen("seasonal")
  expect_identical(
    generator$param_set$values,
    list(
      level = 100,
      trend = 1,
      amplitude = 10,
      sd = 1,
      type = "additive",
      k = 1L,
      freq = "month",
      start = as.Date("2000-01-01")
    )
  )
  task = tgen("seasonal", sd = 0)$generate(24L)
  expect_identical(task$feature_names, character())
  expect_equal(task$truth(), 100 + 1:24 + 10 * sin(2 * pi * 1:24 / 12))
})

test_that("seasonal generator derives the period from freq or takes it explicitly", {
  y_quarterly = tgen("seasonal", sd = 0, freq = "quarter")$generate(8L)$truth()
  expect_equal(y_quarterly, 100 + 1:8 + 10 * sin(2 * pi * 1:8 / 4))
  y_explicit = tgen("seasonal", sd = 0, period = 6)$generate(12L)$truth()
  expect_equal(y_explicit, 100 + 1:12 + 10 * sin(2 * pi * 1:12 / 6))
})

test_that("seasonal generator scales multiplicative seasonality with the trend", {
  y = tgen("seasonal", sd = 0, type = "multiplicative", trend = 100)$generate(12L)$truth()
  base = 100 + 100 * 1:12
  expect_equal(y, base * (1 + 10 * sin(2 * pi * 1:12 / 12) / 100))
  expect_error(tgen("seasonal", type = "multiplicative", level = 0)$generate(12L), "positive trend level")
  expect_error(tgen("seasonal", type = "multiplicative", trend = -10)$generate(12L), "positive trend level")
})

test_that("seasonal generator builds keyed panels", {
  task = tgen("seasonal", k = 2L, freq = "day")$generate(14L)
  expect_identical(task$nrow, 28L)
  expect_identical(task$col_roles$key, "series")
  expect_identical(task$data(cols = "series")[, .N, by = "series"]$N, rep(14L, 2L))
  expect_equal(task$data(cols = "date")[1:14][[1L]], seq(as.Date("2000-01-01"), by = "day", length.out = 14L))
})

test_that("seasonal generator is reproducible", {
  generator = tgen("seasonal", k = 2L)
  task1 = withr::with_seed(1L, generator$generate(40L))
  task2 = withr::with_seed(1L, generator$generate(40L))
  expect_identical(task1$data(), task2$data())
})
