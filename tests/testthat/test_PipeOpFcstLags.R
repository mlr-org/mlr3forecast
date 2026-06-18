test_that("PipeOpFcstLags declares fcst_iterative property", {
  expect_subset("fcst_iterative", po("fcst.lags")$properties)
})

test_that("PipeOpFcstLags rejects non-positive lags", {
  expect_snapshot(po("fcst.lags", lags = 0L), error = TRUE)
  expect_snapshot(po("fcst.lags", lags = c(1L, -1L)), error = TRUE)
})

test_that("PipeOpFcstLags aligns train features on date-major keyed task", {
  task = make_date_major_panel_task()
  out = po("fcst.lags", lags = 1L)$train(list(task))[[1L]]
  res = out$data(cols = c("id", "date", "y", "y_lag_1"))
  setorderv(res, c("id", "date"))
  full = task$data(cols = c("id", "date", "y"))
  setorderv(full, c("id", "date"))
  full[, y_lag_1 := shift(y), by = id]
  full = full[!is.na(y_lag_1)]
  expect_equal(res$y_lag_1, full$y_lag_1)
  expect_equal(res$y, full$y)
})

test_that("PipeOpFcstLags computes predict features from full backend", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  p = po("fcst.lags", lags = 1:2)
  p$train(list(task$clone()$filter(split$train)))

  test_task = task$clone()$filter(split$test)
  out = p$predict(list(test_task))[[1L]]
  lag_cols = sprintf("%s_lag_%i", task$target_names, 1:2)
  expect_subset(lag_cols, out$feature_names)
  expect_false(anyNA(out$data(cols = lag_cols)))
})

test_that("PipeOpFcstLags drops the leading rows without complete lags at train", {
  task = tsk("airpassengers")
  out = po("fcst.lags", lags = 1:3)$train(list(task))[[1L]]
  expect_equal(out$nrow, task$nrow - 3L)
})

test_that("PipeOpFcstLags warns and drops a panel series too short for the lags", {
  data = rbind(
    data.table(date = seq(as.Date("2020-01-01"), by = "day", length.out = 10L), id = "a", y = as.numeric(1:10)),
    data.table(date = seq(as.Date("2020-01-01"), by = "day", length.out = 3L), id = "b", y = as.numeric(1:3))
  )
  data[, id := as.factor(id)]
  task = as_task_fcst(data, target = "y", order = "date", key = "id", freq = "day")
  expect_snapshot(out <- po("fcst.lags", lags = 1:5)$train(list(task))[[1L]])
  expect_equal(as.character(unique(out$data(cols = "id")$id)), "a")
})

test_that("PipeOpFcstLags errors when the whole series is too short for the lags", {
  task = tsk("airpassengers")$clone()$filter(1:3)
  expect_snapshot(po("fcst.lags", lags = 1:5)$train(list(task)), error = TRUE)
})
