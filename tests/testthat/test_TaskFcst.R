test_that("calendar-string freq requires a Date or POSIXct order column", {
  dt = data.table(idx = 1:6, y = as.numeric(1:6))
  expect_error(
    as_task_fcst(dt, target = "y", order = "idx", freq = "month"),
    "calendar `freq`"
  )
  # NULL infers the step of an integer index
  expect_class(as_task_fcst(dt, target = "y", order = "idx"), "TaskFcst")
  # a Date order column still accepts a calendar-string freq
  dd = data.table(d = seq(as.Date("2020-01-01"), by = "month", length.out = 6L), y = as.numeric(1:6))
  expect_class(as_task_fcst(dd, target = "y", order = "d", freq = "month"), "TaskFcst")
})

test_that("freq is inferred from the order column at construction", {
  dt = data.table(d = seq(as.Date("2020-01-01"), by = "month", length.out = 24L), y = as.numeric(1:24))
  task = as_task_fcst(dt, target = "y", order = "d")
  expect_identical(task$freq, "1 month")
  expect_null(task$extra_args$freq)
  expect_identical(stats::frequency(as.ts(task)), 12)
  # the step does not depend on the rows in use
  task$filter(1L)
  expect_identical(generate_newdata(task, 1L)$d, as.Date("2020-02-01"))

  month_end = data.table(d = seq(as.Date("2020-02-01"), by = "month", length.out = 24L) - 1L, y = 1)
  expect_identical(as_task_fcst(month_end, target = "y", order = "d")$freq, "1 month")

  # an error if not all observations are on the inferred grid, or the series have different steps
  irregular = data.table(d = as.Date(c("2020-01-03", "2020-02-05", "2020-03-02", "2020-04-06")), y = 1)
  expect_error(as_task_fcst(irregular, target = "y", order = "d"), "irregular")
  mixed = data.table(
    id = rep(c("a", "b"), each = 6L),
    d = c(
      seq(as.Date("2020-01-01"), by = "month", length.out = 6L),
      seq(as.Date("2020-01-01"), by = "week", length.out = 6L)
    ),
    y = 1
  )
  expect_error(as_task_fcst(mixed, target = "y", order = "d", key = "id"), "different steps")
})

test_that("a given freq is checked against the order column", {
  dt = data.table(d = seq(as.Date("2020-01-01"), by = "month", length.out = 24L), y = as.numeric(1:24))
  expect_error(as_task_fcst(dt, target = "y", order = "d", freq = "2 month"), "does not match")
  expect_error(as_task_fcst(dt, target = "y", order = "d", freq = "day"), "is finer than")
  expect_error(as_task_fcst(dt, target = "y", order = "d", freq = "hour"), "sub-daily")
  # gaps are allowed
  expect_identical(as_task_fcst(dt[-(5:7)], target = "y", order = "d", freq = "month")$freq, "month")
  # a month-end series starting on a clamped day is on the monthly grid
  month_end = data.table(d = seq(as.Date("2020-03-01"), by = "month", length.out = 24L) - 1L, y = 1)
  expect_identical(as_task_fcst(month_end, target = "y", order = "d", freq = "month")$freq, "month")
})

test_that("freq can be set and is resolved again when the order or key columns change", {
  dt = data.table(
    d = seq(as.Date("2020-01-01"), by = "month", length.out = 24L),
    w = seq(as.Date("2020-01-06"), by = "week", length.out = 24L),
    i = 1:24,
    y = as.numeric(1:24)
  )
  task = as_task_fcst(dt, target = "y", order = "d")
  task$col_roles$order = "w"
  expect_identical(task$freq, "1 week")
  task$col_roles$order = "i"
  expect_identical(task$freq, 1L)

  task = as_task_fcst(dt, target = "y", order = "d", freq = "month")
  expect_identical(task$extra_args$freq, "month")
  task$col_roles$order = "w"
  expect_error(task$freq, "does not match")
  task$freq = NULL
  expect_identical(task$freq, "1 week")
  expect_null(task$extra_args$freq)
  expect_error({
    task$freq = "2 week"
  }, "does not match")
  task$freq = "week"
  expect_identical(task$extra_args$freq, "week")

  # a new backend, as in predict_newdata(), keeps the step
  task = as_task_fcst(dt, target = "y", order = "d")
  task$backend = as_data_backend(dt[24L])
  expect_identical(task$freq, "1 month")
})

test_that("view includes key and order columns", {
  skip_if_not_installed("tsibbledata")
  skip_if_not_installed("tsibble")

  task = tsk("livestock")
  v = task$view(cols = "count")
  expect_names(names(v), identical.to = c("animal", "state", "month", "count"))

  v = task$view(ordered = TRUE)
  expect_data_table(v, nrows = task$nrow)
  expect_names(names(v), must.include = c("animal", "state", "month", "count"))
})

test_that("order binding returns row_id and order columns", {
  task = tsk("airpassengers")
  o = task$order
  expect_data_table(o, nrows = task$nrow)
  expect_names(names(o), identical.to = c("row_id", "order"))
})

test_that("key binding returns row_id and key columns", {
  skip_if_not_installed("tsibbledata")
  skip_if_not_installed("tsibble")

  expect_null(tsk("airpassengers")$key)

  task = tsk("livestock")
  k = task$key
  expect_data_table(k, nrows = task$nrow)
  expect_names(names(k), identical.to = c("row_id", "animal", "state"))

  dt = data.table(
    date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2L),
    value = rnorm(20L),
    id = factor(rep(c("a", "b"), each = 10L))
  )
  task = as_task_fcst(dt, target = "value", order = "date", key = "id")
  expect_names(names(task$key), identical.to = c("row_id", "key"))
})

test_that("character keys are structural-only by default", {
  data = data.frame(
    date = rep(as.Date("2025-01-01") + 0:2, 2L),
    region = rep(c("north", "south"), each = 3L),
    value = rnorm(6L),
    stringsAsFactors = FALSE
  )
  task = as_task_fcst(data, target = "value", order = "date", key = "region")

  expect_identical(task$col_roles$key, "region")
  expect_length(intersect(task$col_roles$key, task$feature_names), 0L)
  expect_character(task$data(cols = "region")$region)
  expect_character(task$key$key)

  task$set_col_roles("region", add_to = "feature")
  expect_true("region" %in% task$feature_names)
})

test_that("integer keys are structural-only by default", {
  data = data.frame(
    date = rep(as.Date("2025-01-01") + 0:2, 2L),
    store = rep(c(1L, 2L), each = 3L),
    value = rnorm(6L)
  )
  task = as_task_fcst(data, target = "value", order = "date", key = "store")

  expect_identical(task$col_roles$key, "store")
  expect_length(intersect(task$col_roles$key, task$feature_names), 0L)
  expect_integer(task$data(cols = "store")$store)
  expect_integer(task$key$key)
})

test_that("a column may not be both order and key", {
  dt = data.table(idx = rep(1:5, 2L), store = rep(c(1L, 2L), each = 5L), y = rnorm(10L))
  expect_error(
    TaskFcst$new("t", as_data_backend(dt), target = "y", order = "idx", key = "idx"),
    "both the 'order' and the 'key' role"
  )

  task = as_task_fcst(dt, target = "y", order = "idx", key = "store")
  expect_error(
    task$set_col_roles("idx", add_to = "key"),
    "both the 'order' and the 'key' role"
  )
})

test_that("a key column may not be the target", {
  dt = data.table(idx = rep(1:5, 2L), store = rep(c(1L, 2L), each = 5L), y = rnorm(10L))
  task = as_task_fcst(dt, target = "y", order = "idx", key = "store")
  expect_error(
    task$set_col_roles("y", add_to = "key"),
    "may not also be the target"
  )
})

test_that("numeric key columns are rejected", {
  data = data.frame(
    date = rep(as.Date("2025-01-01") + 0:2, 2L),
    store = rep(c(1.5, 2.5), each = 3L),
    value = rnorm(6L)
  )
  expect_error(
    as_task_fcst(data, target = "value", order = "date", key = "store"),
    "must be character, integer, factor, or ordered"
  )
})

test_that("feature preprocessing ignores structural keys", {
  data = data.frame(
    date = as.Date("2025-01-01") + 0:5,
    region = factor(rep("HCMC", 6L)),
    value = rnorm(6L),
    covariate = rnorm(6L),
    stringsAsFactors = FALSE
  )
  task = as_task_fcst(data, target = "value", order = "date", key = "region")

  encoded = po("encode", affect_columns = selector_type("factor"))$train(list(task))[[1L]]

  expect_identical(encoded$col_roles$key, "region")
  expect_false("region" %in% encoded$feature_names)
  expect_factor(encoded$data(cols = "region")$region)
})

test_that("order column may not contain missing values", {
  dt = data.table(date = seq(as.Date("2025-01-01"), length.out = 10L), y = rnorm(10L))
  dt[5L, date := NA]
  expect_error(
    as_task_fcst(dt, target = "y", order = "date"),
    "Order column 'date' must not contain missing values"
  )
  # the role layer guards direct construction too
  expect_error(
    TaskFcst$new(id = "t", backend = dt, target = "y", order = "date"),
    "Order column 'date' contains missing values"
  )
})

test_that("key columns may not contain missing values", {
  dt = data.table(
    date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2L),
    value = rnorm(20L),
    id = factor(rep(c("a", "b"), each = 10L))
  )
  dt[16:20, id := NA]
  expect_error(
    as_task_fcst(dt, target = "value", order = "date", key = "id"),
    "Key column\\(s\\) 'id' must not contain missing values"
  )

  # a single NA in one column of a multi-column key
  dt = data.table(
    date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2L),
    value = rnorm(20L),
    id = factor(rep(c("a", "b"), each = 10L)),
    region = factor(rep(c("x", "y"), each = 10L))
  )
  dt[20L, region := NA]
  expect_error(
    as_task_fcst(dt, target = "value", order = "date", key = c("id", "region")),
    "must not contain missing values"
  )

  # the role layer reports the offending column
  expect_error(
    TaskFcst$new(id = "t", backend = dt, target = "value", order = "date", key = c("id", "region")),
    "Key column\\(s\\) 'region' contain missing values"
  )

  # assigning the key role later is checked too
  task = as_task_fcst(dt, target = "value", order = "date", key = "id")
  expect_error(
    task$set_col_roles("region", add_to = "key"),
    "missing values"
  )

  # an explicit "unknown" level is allowed
  dt = data.table(
    date = rep.int(seq(as.Date("2025-01-01"), length.out = 10L), 2L),
    value = rnorm(20L),
    id = factor(rep(c("a", "unknown"), each = 10L))
  )
  task = as_task_fcst(dt, target = "value", order = "date", key = "id")
  expect_class(task, "TaskFcst")
})

test_that("print shows the frequency", {
  task = as_task_fcst(data.table(idx = 1:5, y = rnorm(5)), target = "y", order = "idx")
  out = capture.output(print(task))
  expect_match(out, "Frequency: 1", all = FALSE)
})

test_that("a numeric order column always has a numeric freq", {
  dt = data.table(i = 1:12, y = as.numeric(1:12))
  expect_identical(as_task_fcst(dt, target = "y", order = "i")$freq, 1L)
  expect_identical(as_task_fcst(dt[1L], target = "y", order = "i")$freq, 1L)
  expect_identical(as_task_fcst(dt, target = "y", order = "i", freq = 1)$freq, 1L)
  # gaps are allowed, the step is the greatest common divisor of the gaps
  expect_identical(as_task_fcst(dt[c(1, 2, 4, 7)], target = "y", order = "i")$freq, 1L)
  expect_identical(as_task_fcst(dt[c(1, 3, 7)], target = "y", order = "i")$freq, 2L)
  expect_identical(as_task_fcst(data.table(i = seq(0, 5, by = 0.5), y = 1), target = "y", order = "i")$freq, 0.5)
  # a numeric freq is the step, not the seasonal period
  expect_error(as_task_fcst(dt, target = "y", order = "i", freq = 12), "does not match")
  dd = data.table(d = seq(as.Date("2020-01-01"), by = "month", length.out = 12L), y = 1)
  expect_error(as_task_fcst(dd, target = "y", order = "d", freq = 12), "numeric `freq`")
  mixed = data.table(id = rep(c("a", "b"), each = 6L), i = c(1:6, seq(0L, 50L, by = 10L)), y = 1)
  expect_error(as_task_fcst(mixed, target = "y", order = "i", key = "id"), "different steps")
})

test_that("as.ts works", {
  task = tsk("airpassengers")
  ts = as.ts(task)
  expect_class(ts, "ts")
  expect_length(ts, task$nrow)
  expect_identical(stats::frequency(ts), 12)
  expect_error(as.ts(task, freq = 4), "no longer takes `freq`")
})

test_that("as.ts derives the default period from freq and accepts an explicit one", {
  daily = as_task_fcst(
    data.table(d = seq(as.Date("2020-01-01"), by = "day", length.out = 40L), y = as.numeric(1:40)),
    target = "y",
    order = "d",
    freq = "day"
  )
  expect_identical(stats::frequency(as.ts(daily)), 7)
  expect_identical(stats::frequency(as.ts(daily, period = 365)), 365)
  expect_identical(stats::frequency(as.ts(daily, period = "year")), 365.25)
  expect_error(as.ts(daily, period = c(7, 365)), "positive number")

  # an integer index has no calendar cycle to derive or resolve a period from
  task = as_task_fcst(data.table(i = 1:24, y = as.numeric(1:24)), target = "y", order = "i")
  expect_identical(stats::frequency(as.ts(task)), 1)
  expect_identical(stats::frequency(as.ts(task, period = 12)), 12)
  expect_error(as.ts(task, period = "year"), "requires a calendar `freq`")
})
