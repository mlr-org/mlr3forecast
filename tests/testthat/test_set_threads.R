skip_if_not_installed("forecast")

test_that("set_threads sets the threads-tagged param", {
  ids = c("fcst.arfima", "fcst.auto_arima", "fcst.nnetar", "fcst.bats", "fcst.tbats")
  for (id in ids) {
    learner = set_threads(lrn(id), 2L)
    expect_identical(learner$param_set$ids(tags = "threads"), "num.cores", info = id)
    expect_identical(learner$param_set$values$num.cores, 2L, info = id)
  }
})

test_that("num.cores alone enables the parallel switch at train", {
  task = tsk("airpassengers")$filter(1:72)
  learner = set_threads(lrn("fcst.bats", use.box.cox = FALSE, use.trend = FALSE), 2L)
  expect_false("use.parallel" %in% names(learner$param_set$values))
  learner$train(task)
  expect_true(learner$native_model$call$use.parallel)
  expect_numeric(learner$predict(task)$response, any.missing = FALSE, len = task$nrow)
})

test_that("a single thread stays serial", {
  task = tsk("airpassengers")$filter(1:72)
  learner = set_threads(lrn("fcst.bats", use.box.cox = FALSE, use.trend = FALSE), 1L)
  learner$train(task)
  expect_null(learner$native_model$call$use.parallel)
})

test_that("an explicit parallel switch is not overridden", {
  task = tsk("airpassengers")$filter(1:72)
  learner = lrn("fcst.bats", use.box.cox = FALSE, use.trend = FALSE, use.parallel = FALSE, num.cores = 2L)
  learner$train(task)
  expect_numeric(learner$predict(task)$response, any.missing = FALSE, len = task$nrow)
})
