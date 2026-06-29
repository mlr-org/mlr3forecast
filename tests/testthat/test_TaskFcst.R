test_that("calendar-string freq requires a Date or POSIXct order column", {
  dt = data.table(idx = 1:6, y = as.numeric(1:6))
  expect_error(
    as_task_fcst(dt, target = "y", order = "idx", freq = "month"),
    "calendar `freq`"
  )
  # a numeric freq (seasonal period) or NULL is allowed on an integer index
  expect_class(as_task_fcst(dt, target = "y", order = "idx", freq = 1), "TaskFcst")
  expect_class(as_task_fcst(dt, target = "y", order = "idx"), "TaskFcst")
  # a Date order column still accepts a calendar-string freq
  dd = data.table(d = seq(as.Date("2020-01-01"), by = "month", length.out = 6L), y = as.numeric(1:6))
  expect_class(as_task_fcst(dd, target = "y", order = "d", freq = "month"), "TaskFcst")
})

test_that("view includes key and order columns", {
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

test_that("print omits frequency when NULL", {
  task = as_task_fcst(data.table(idx = 1:5, y = rnorm(5)), target = "y", order = "idx")
  out = capture.output(print(task))
  expect_no_match(out, "Frequency")
})
