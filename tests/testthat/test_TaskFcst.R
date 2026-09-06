test_that("calendar-string freq requires a Date or POSIXct order column", {
  dt = data.table(idx = 1:6, y = as.numeric(1:6))
  expect_error(
    as_task_fcst(dt, target = "y", order = "idx", freq = "month"),
    "calendar `freq`"
  )
  # a numeric freq (the index step) or NULL is allowed on an integer index
  expect_class(as_task_fcst(dt, target = "y", order = "idx", freq = 1), "TaskFcst")
  expect_class(as_task_fcst(dt, target = "y", order = "idx"), "TaskFcst")
  # a Date order column still accepts a calendar-string freq
  dd = data.table(d = seq(as.Date("2020-01-01"), by = "month", length.out = 6L), y = as.numeric(1:6))
  expect_class(as_task_fcst(dd, target = "y", order = "d", freq = "month"), "TaskFcst")
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

test_that("print omits frequency when NULL", {
  task = as_task_fcst(data.table(idx = 1:5, y = rnorm(5)), target = "y", order = "idx")
  out = capture.output(print(task))
  expect_no_match(out, "Frequency")
})

test_that("period defaults to the cycle implied by freq", {
  expect_equal(tsk("airpassengers")$period, c(year = 12))
  expect_equal(tsk("livestock")$period, c(year = 12))
  daily = as_task_fcst(
    data.table(d = seq(as.Date("2020-01-01"), by = "day", length.out = 40L), y = as.numeric(1:40)),
    target = "y",
    order = "d",
    freq = "day"
  )
  expect_equal(daily$period, c(week = 7))
  expect_equal(common_periods(daily), c(week = 7, year = 365.25))
})

test_that("period overrides the cycle implied by freq", {
  dt = data.table(d = seq(as.Date("2020-01-01"), by = "day", length.out = 40L), y = as.numeric(1:40))
  expect_equal(as_task_fcst(dt, target = "y", order = "d", freq = "day", period = 365)$period, 365)
  # a cycle name is resolved against freq at construction
  expect_equal(as_task_fcst(dt, target = "y", order = "d", freq = "day", period = "year")$period, c(year = 365.25))
  # multiple seasonalities are kept, shortest first by convention
  expect_equal(as_task_fcst(dt, target = "y", order = "d", freq = "day", period = c(7, 365))$period, c(7, 365))
})

test_that("period carries seasonality for an index without calendar meaning", {
  dt = data.table(i = 1:48, y = as.numeric(1:48))
  expect_equal(as_task_fcst(dt, target = "y", order = "i")$period, c(none = 1))
  expect_equal(as_task_fcst(dt, target = "y", order = "i", period = 12)$period, 12)
  # a cycle name has nothing to resolve against
  expect_error(as_task_fcst(dt, target = "y", order = "i", period = "year"), "requires a calendar `freq`")
})

test_that("numeric freq is the index step and requires a numeric order column", {
  dd = data.table(d = seq(as.Date("2020-01-01"), by = "month", length.out = 12L), y = as.numeric(1:12))
  expect_error(as_task_fcst(dd, target = "y", order = "d", freq = 12), "step between observations")

  dt = data.table(i = seq(0, by = 3, length.out = 12L), y = as.numeric(1:12))
  task = as_task_fcst(dt, target = "y", order = "i", freq = 3)
  expect_equal(generate_newdata(task, 2L)$i, c(36, 39))
  # a step that contradicts the data is rejected
  bad = as_task_fcst(dt, target = "y", order = "i", freq = 2)
  expect_error(generate_newdata(bad, 1L), "irregular series")
})

test_that("period round-trips through the task's extra_args", {
  dt = data.table(i = 1:24, y = as.numeric(1:24))
  task = as_task_fcst(dt, target = "y", order = "i", period = 12)
  expect_equal(task$extra_args$period, 12)
  expect_equal(task$clone(deep = TRUE)$period, 12)
})
