test_that("assert_freq accepts valid inputs", {
  # NULL
  expect_null(assert_freq(NULL, null.ok = TRUE))

  # bare unit words
  expect_identical(assert_freq("day"), "day")
  expect_identical(assert_freq("month"), "month")
  expect_identical(assert_freq("year"), "year")
  expect_identical(assert_freq("quarter"), "quarter")
  expect_identical(assert_freq("week"), "week")
  expect_identical(assert_freq("hour"), "hour")
  expect_identical(assert_freq("min"), "min")
  expect_identical(assert_freq("sec"), "sec")

  # plural forms
  expect_identical(assert_freq("days"), "days")
  expect_identical(assert_freq("months"), "months")
  expect_identical(assert_freq("secs"), "secs")

  # with multiplier
  expect_identical(assert_freq("1 month"), "1 month")
  expect_identical(assert_freq("3 months"), "3 months")
  expect_identical(assert_freq("30 mins"), "30 mins")
  expect_identical(assert_freq("12 hours"), "12 hours")
})

test_that("assert_freq rejects invalid inputs", {
  expect_error(assert_freq(NULL), "Must be a string")
  # a number is the seasonal period, which is not part of the task
  expect_error(assert_freq(12L), "not a number")
  expect_error(assert_freq(365.25), "not a number")
  expect_error(assert_freq(-1))
  expect_error(assert_freq(0))
  expect_error(assert_freq(0L))
  expect_error(assert_freq(Inf))
  expect_error(assert_freq(NA))
  expect_error(assert_freq(""))
  expect_error(assert_freq("foo"))
  expect_error(assert_freq("0 months"))
  expect_error(assert_freq("-1 days"))
  expect_error(assert_freq("1 2 months"))
  expect_error(assert_freq(TRUE))
  expect_error(assert_freq("m"))
})

test_that("check_period accepts a single period unless multiple are allowed", {
  expect_true(check_period(NULL))
  expect_true(check_period(12))
  expect_true(check_period("year"))
  expect_string(check_period(c(7, 365)), pattern = "positive number")
  expect_true(check_period(c(7, 365), multiple = TRUE))
  expect_true(check_period(c("week", "year"), multiple = TRUE))
  expect_string(check_period(0), pattern = "positive number")
})
