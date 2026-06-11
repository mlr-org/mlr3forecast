test_that("RecursiveForecaster basic train/predict works", {
  task = tsk("airpassengers")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("RecursiveForecaster iterative prediction updates lags", {
  task = tsk("airpassengers")
  learner = RecursiveForecaster$new(lrn("regr.rpart", minsplit = 2L, cp = 0), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  # predictions should not all be identical since lags update between steps
  expect_false(length(unique(prediction$response)) == 1L)
})

test_that("RecursiveForecaster works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("RecursiveForecaster works with graph constructor", {
  task = tsk("airpassengers")
  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  learner = RecursiveForecaster$new(graph)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("RecursiveForecaster warns without iterative PipeOps", {
  task = tsk("airpassengers")
  task$col_roles$feature = "month"
  graph = po("colapply", applicator = as.numeric) %>>% lrn("regr.rpart")
  expect_warning(RecursiveForecaster$new(graph), "recursive")
})

test_that("RecursiveForecaster does not truncate predictions fed back into integer targets", {
  y = withr::with_seed(1, as.integer(round(100 + 10 * sin(seq_len(60) / 3) + rnorm(60, sd = 2))))
  dates = seq(as.Date("2020-01-01"), by = "day", length.out = 60L)
  make_task = function(y) {
    TaskFcst$new("t", as_data_backend(data.table(y = y, date = dates)), target = "y", order = "date", freq = "day")
  }
  task_int = make_task(y)
  task_dbl = make_task(as.numeric(y))

  flrn_int = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)$train(task_int, 1:50)
  flrn_dbl = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)$train(task_dbl, 1:50)
  expect_no_warning(p_int <- flrn_int$predict(task_int, 51:60))
  p_dbl = flrn_dbl$predict(task_dbl, 51:60)
  expect_equal(p_int$response, p_dbl$response)
})

test_that("RecursiveForecaster handles predict rows overlapping training rows", {
  task = tsk("airpassengers")
  flrn = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)$train(task)
  prediction = flrn$predict(task, 140:144)
  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, 5L)
})

test_that("RecursiveForecaster errors when test rows do not continue the training grid", {
  task = tsk("airpassengers")
  flrn = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task, 1:120)
  expect_snapshot(flrn$predict(task, 126:130), error = TRUE)
  expect_snapshot(flrn$predict(task, c(121L, 123L)), error = TRUE)
})

test_that("RecursiveForecaster errors on gapped keyed test rows", {
  task = make_date_major_panel_task(10L)
  flrn = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:2)
  flrn$train(task, 1:16)
  expect_snapshot(flrn$predict(task, 19:20), error = TRUE)
})

test_that("RecursiveForecaster errors on target trafo inside the graph", {
  inner = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  graph = ppl("targettrafo", graph = inner, trafo_pipeop = po("fcst.targetdiff", lag = 1L))
  expect_snapshot(RecursiveForecaster$new(graph), error = TRUE)
})

test_that("RecursiveForecaster works wrapped in a target trafo", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.85)
  flrn = as_learner(ppl(
    "targettrafo",
    graph = as_learner_fcst(lrn("regr.rpart"), lags = 1:12),
    trafo_pipeop = po("fcst.targetdiff", lag = 1L)
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
  # predictions are inverted back to the original scale, not the differenced scale
  expect_numeric(prediction$response, lower = 100, finite = TRUE, any.missing = FALSE)
})

test_that("as_learner_fcst helper works", {
  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  expect_class(learner, "RecursiveForecaster")
  expect_class(learner, "Learner")
  expect_equal(learner$lags, 1:3)

  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  learner = as_learner_fcst(graph)
  expect_class(learner, "RecursiveForecaster")
  expect_equal(learner$lags, 1:3)
})

test_that("RecursiveForecaster lags active binding", {
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:5)
  expect_equal(learner$lags, 1:5)

  graph = po("colapply", applicator = as.numeric) %>>% lrn("regr.rpart")
  learner = expect_warning(RecursiveForecaster$new(graph), "recursive")
  expect_null(learner$lags)
})
