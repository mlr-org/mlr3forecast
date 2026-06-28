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

test_that("infer_freq honors non-unit spacing for numeric and integer order", {
  expect_equal(infer_freq(seq(0L, by = 2L, length.out = 10L)), 2)
  expect_equal(infer_freq(seq(0, by = 0.5, length.out = 10L)), 0.5)
  # unsorted input is still handled
  expect_equal(infer_freq(c(6L, 0L, 2L, 4L)), 2)
  # step-1 index keeps the historical default
  expect_equal(infer_freq(1:10), 1)
  # too short to infer
  expect_equal(infer_freq(5L), 1L)
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

test_that("to_tsibble_index maps calendar units and passes through the rest", {
  d = seq(as.Date("2020-01-01"), by = "month", length.out = 4L)
  expect_class(to_tsibble_index(d, "week"), "yearweek")
  expect_class(to_tsibble_index(d, "month"), "yearmonth")
  expect_class(to_tsibble_index(d, "quarter"), "yearquarter")
  y = seq(as.Date("2000-01-01"), by = "year", length.out = 4L)
  expect_equal(to_tsibble_index(y, "year"), c(2000L, 2001L, 2002L, 2003L))
  expect_identical(to_tsibble_index(d, "day"), d)
  expect_identical(to_tsibble_index(d, 12), d)
  expect_identical(to_tsibble_index(2000:2003, "year"), 2000:2003)
})

test_that("quantiles_to_levels dedupes floating-point levels", {
  expect_equal(quantiles_to_levels(c(0.05, 0.1, 0.9, 0.95)), c(80, 90))
  expect_equal(quantiles_to_levels(c(0.05, 0.5, 0.95)), 90)
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

test_that("freq_to_period maps single-unit freqs to seasonal periods", {
  expect_equal(freq_to_period("month"), 12)
  expect_equal(freq_to_period("1 month"), 12)
  expect_equal(freq_to_period("quarter"), 4)
  expect_equal(freq_to_period("week"), 52.18)
  expect_equal(freq_to_period("day"), 365.25)
  expect_equal(freq_to_period("hour"), 24)
  expect_equal(freq_to_period("year"), 1)
})

test_that("freq_to_period handles multi-count freqs", {
  expect_equal(freq_to_period("3 months"), 4)
  expect_equal(freq_to_period("6 months"), 2)
  expect_equal(freq_to_period("2 month"), 6)
  expect_equal(freq_to_period("30 min"), 48)
  expect_equal(freq_to_period("15 mins"), 96)
  expect_equal(freq_to_period("6 hours"), 4)
  expect_equal(freq_to_period("2 day"), 365.25 / 2)
})

test_that("freq_to_period passes through numeric and falls back for unknown", {
  expect_equal(freq_to_period(12), 12)
  expect_identical(freq_to_period(NULL), 1L)
  expect_identical(freq_to_period("nonsense"), 1L)
})

test_that("calendar_months maps overflow-prone freqs and returns NA otherwise", {
  expect_identical(calendar_months("month"), 1L)
  expect_identical(calendar_months("2 month"), 2L)
  expect_identical(calendar_months("quarter"), 3L)
  expect_identical(calendar_months("year"), 12L)
  expect_identical(calendar_months("week"), NA_integer_)
  expect_identical(calendar_months("3 day"), NA_integer_)
  expect_identical(calendar_months(12), NA_integer_)
  # plural unit names are valid seq.Date freqs and must map like their singular form
  expect_identical(calendar_months("months"), 1L)
  expect_identical(calendar_months("2 months"), 2L)
  expect_identical(calendar_months("quarters"), 3L)
  expect_identical(calendar_months("years"), 12L)
})

test_that("seq_order clamps month-end for plural freqs too", {
  expect_identical(
    seq_order(as.Date("2020-07-31"), "2 months", 3L),
    as.Date(c("2020-09-30", "2020-11-30", "2021-01-31"))
  )
})

test_that("seq_order preserves day-of-month like seq.Date for days 1-28", {
  for (d in c("2020-01-15", "2020-01-20", "2020-01-28")) {
    expected = seq(as.Date(d), by = "month", length.out = 4L)[-1L]
    expect_identical(seq_order(as.Date(d), "month", 3L), expected)
  }
})

test_that("seq_order carries a sub-31 month-end origin forward on its day-of-month (no eom snap)", {
  # month-end anchoring is not inferred: Apr-30 is treated as the 30th, clamped where shorter
  expect_identical(
    seq_order(as.Date("2020-04-30"), "month", 3L),
    as.Date(c("2020-05-30", "2020-06-30", "2020-07-30"))
  )
  # a 28th-anchored origin (non-leap Feb-28) stays on the 28th, not snapped to month-end
  expect_identical(
    seq_order(as.Date("2021-02-28"), "month", 3L),
    as.Date(c("2021-03-28", "2021-04-28", "2021-05-28"))
  )
})

test_that("seq_order clamps days 29-31 instead of overflowing", {
  # day 31 origin lands on each target month's last day
  expect_identical(
    seq_order(as.Date("2020-01-31"), "month", 3L),
    as.Date(c("2020-02-29", "2020-03-31", "2020-04-30"))
  )
  # day 30 origin clamps only where the month is shorter
  expect_identical(
    seq_order(as.Date("2020-01-30"), "month", 3L),
    as.Date(c("2020-02-29", "2020-03-30", "2020-04-30"))
  )
  # no result ever overflows into a later month
  out = seq_order(as.Date("2021-01-31"), "month", 12L)
  expect_true(all(month(out) == c(2:12, 1L)))
})

test_that("seq_order handles quarter and year and passes other freqs to seq.Date", {
  expect_identical(
    seq_order(as.Date("2020-12-31"), "quarter", 3L),
    as.Date(c("2021-03-31", "2021-06-30", "2021-09-30"))
  )
  expect_identical(
    seq_order(as.Date("2020-02-29"), "year", 2L),
    as.Date(c("2021-02-28", "2022-02-28"))
  )
  for (f in c("week", "3 day")) {
    expect_identical(
      seq_order(as.Date("2020-01-13"), f, 3L),
      seq(as.Date("2020-01-13"), by = f, length.out = 4L)[-1L]
    )
  }
})

test_that("seq_order keeps POSIXct type, tzone and time-of-day on the calendar path", {
  origin = as.POSIXct("2020-01-31 09:30:00", tz = "UTC")
  out = seq_order(origin, "month", 3L)
  expect_s3_class(out, "POSIXct")
  expect_identical(
    out,
    as.POSIXct(c("2020-02-29 09:30:00", "2020-03-31 09:30:00", "2020-04-30 09:30:00"), tz = "UTC")
  )
  # non-calendar freqs still match seq.POSIXt exactly
  expect_identical(
    seq_order(origin, "week", 2L),
    seq(origin, by = "week", length.out = 3L)[-1L]
  )
})
