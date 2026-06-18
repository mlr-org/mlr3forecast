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

test_that("freq_to_int maps single-unit freqs to seasonal periods", {
  expect_equal(freq_to_int("month"), 12)
  expect_equal(freq_to_int("1 month"), 12)
  expect_equal(freq_to_int("quarter"), 4)
  expect_equal(freq_to_int("week"), 52.18)
  expect_equal(freq_to_int("day"), 365.25)
  expect_equal(freq_to_int("hour"), 24)
  expect_equal(freq_to_int("year"), 1)
})

test_that("freq_to_int handles multi-count freqs", {
  expect_equal(freq_to_int("3 months"), 4)
  expect_equal(freq_to_int("6 months"), 2)
  expect_equal(freq_to_int("2 month"), 6)
  expect_equal(freq_to_int("30 min"), 48)
  expect_equal(freq_to_int("15 mins"), 96)
  expect_equal(freq_to_int("6 hours"), 4)
  expect_equal(freq_to_int("2 day"), 365.25 / 2)
})

test_that("freq_to_int passes through numeric and falls back for unknown", {
  expect_equal(freq_to_int(12), 12)
  expect_identical(freq_to_int(NULL), 1L)
  expect_identical(freq_to_int("nonsense"), 1L)
})
