test_that("selector_fcst_lags matches lag features", {
  task = tsk("airpassengers")
  new_task = po("fcst.lags", lags = c(1L, 3L, 12L))$train(list(task))[[1L]]
  selected = selector_fcst_lags()(new_task)
  expect_set_equal(selected, c("passengers_lag_1", "passengers_lag_3", "passengers_lag_12"))
})

test_that("selector_fcst_lags ignores non-lag features", {
  task = tsk("airpassengers")
  task$set_col_roles("month", add = "feature")
  new_task = po("fcst.lags", lags = 1:2)$train(list(task))[[1L]]
  selected = selector_fcst_lags()(new_task)
  expect_set_equal(selected, c("passengers_lag_1", "passengers_lag_2"))
})

test_that("selector_fcst_rolling matches rolling features", {
  task = tsk("airpassengers")
  new_task = po("fcst.rolling", funs = c("mean", "sd"), window_sizes = c(3L, 12L))$train(list(task))[[1L]]
  selected = selector_fcst_rolling()(new_task)
  expect_set_equal(
    selected,
    c(
      "passengers_roll_mean_3",
      "passengers_roll_mean_12",
      "passengers_roll_sd_3",
      "passengers_roll_sd_12"
    )
  )
})

test_that("selector_fcst_rolling ignores non-rolling features", {
  task = tsk("airpassengers")
  graph = po("fcst.lags", lags = 1:2) %>>% po("fcst.rolling", funs = "mean", window_sizes = 3L)
  new_task = graph$train(task)[[1L]]
  selected = selector_fcst_rolling()(new_task)
  expect_set_equal(selected, "passengers_roll_mean_3")
})
