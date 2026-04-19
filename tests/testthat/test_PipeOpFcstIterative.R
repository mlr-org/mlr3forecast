test_that("built-in iterative PipeOps inherit from PipeOpFcstIterative", {
  expect_true(inherits(po("fcst.lags"), "PipeOpFcstIterative"))
  expect_true(inherits(po("fcst.rolling"), "PipeOpFcstIterative"))
})

test_that("update_history errors on untrained PipeOp", {
  p = po("fcst.lags", lags = 1:3)
  expect_error(p$update_history(data.table(x = 1)), "no state")
})

test_that("default update_history appends to history", {
  task = tsk("airpassengers")
  p = po("fcst.lags", lags = 1:3)
  p$train(list(task))

  n_before = nrow(p$state$history)
  new_row = task$data(rows = task$row_ids[1], cols = c(task$target_names, task$col_roles$order))
  p$update_history(new_row)
  expect_equal(nrow(p$state$history), n_before + 1L)
})
