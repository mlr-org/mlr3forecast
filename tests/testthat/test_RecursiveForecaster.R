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

test_that("as_learner_fcst helper works", {
  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  expect_class(learner, "RecursiveForecaster")
  expect_class(learner, "GraphLearner")
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
