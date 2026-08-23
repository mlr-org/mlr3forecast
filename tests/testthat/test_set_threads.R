skip_if_not_installed("forecast")
skip_if_not_installed("smooth")

test_that("set_threads sets the threads-tagged param", {
  learners = list(
    fcst.arfima = "num.cores",
    fcst.auto_arima = "num.cores",
    fcst.nnetar = "num.cores",
    fcst.bats = "num.cores",
    fcst.tbats = "num.cores",
    fcst.auto_adam = "parallel"
  )
  for (id in names(learners)) {
    learner = set_threads(lrn(id), 2L)
    expect_identical(learner$param_set$ids(tags = "threads"), learners[[id]], info = id)
    expect_identical(learner$param_set$values[[learners[[id]]]], 2L, info = id)
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

test_that("fcst.auto_adam accepts a flag or a positive core count", {
  expect_identical(lrn("fcst.auto_adam", parallel = TRUE)$param_set$values$parallel, TRUE)
  expect_identical(lrn("fcst.auto_adam", parallel = 2L)$param_set$values$parallel, 2L)
  expect_error(lrn("fcst.auto_adam", parallel = 0L), "flag or a positive integer")
})

test_that("an explicit parallel switch is not overridden", {
  task = tsk("airpassengers")$filter(1:72)
  learner = lrn("fcst.bats", use.box.cox = FALSE, use.trend = FALSE, use.parallel = FALSE, num.cores = 2L)
  learner$train(task)
  expect_numeric(learner$predict(task)$response, any.missing = FALSE, len = task$nrow)
})
