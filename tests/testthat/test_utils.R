test_that("generate_newdata works with integer order", {
  task = tsk("airpassengers")
  newdata = generate_newdata(task)
  expect_data_table(newdata, nrows = 1L)
  expect_names(names(newdata), must.include = c("month", "passengers"))
  expect_true(allMissing(newdata$passengers))

  newdata = generate_newdata(task, n = 5L)
  expect_data_table(newdata, nrows = 5L)
  expect_true(allMissing(newdata$passengers))
})

test_that("generate_newdata works with Date order", {
  task = tsk("airpassengers")
  newdata = generate_newdata(task, n = 3L)
  expect_data_table(newdata, nrows = 3L)
  expect_class(newdata$month, "Date")
  # dates should be sequential
  expect_true(all(diff(newdata$month) > 0L))
})

test_that("generate_newdata works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  newdata = generate_newdata(task, n = 2L)
  key_cols = task$col_roles$key
  n_keys = uniqueN(task$data(cols = key_cols), by = key_cols)
  expect_data_table(newdata, nrows = 2L * n_keys)
  expect_true(allMissing(newdata[[task$target_names]]))
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
