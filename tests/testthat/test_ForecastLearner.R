test_that("ForecastLearner basic train/predict works", {
  task = tsk("airpassengers")
  learner = ForecastLearner$new(lrn("regr.rpart"), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("ForecastLearner iterative prediction updates lags", {
  task = tsk("airpassengers")
  learner = ForecastLearner$new(lrn("regr.rpart", minsplit = 2L, cp = 0), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  # predictions should not all be identical since lags update between steps
  expect_false(length(unique(prediction$response)) == 1L)
})

test_that("ForecastLearner works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  learner = ForecastLearner$new(lrn("regr.rpart"), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("ForecastLearner works with graph constructor", {
  task = tsk("airpassengers")
  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  learner = ForecastLearner$new(graph)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("ForecastLearner warns without iterative PipeOps", {
  task = tsk("airpassengers")
  task$col_roles$feature = "month"
  graph = po("colapply", applicator = as.numeric) %>>% lrn("regr.rpart")
  expect_warning(ForecastLearner$new(graph), "recursive")
})

test_that("as_learner_fcst helper works", {
  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  expect_class(learner, "ForecastLearner")
  expect_class(learner, "GraphLearner")
  expect_equal(learner$lags, 1:3)

  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  learner = as_learner_fcst(graph)
  expect_class(learner, "ForecastLearner")
  expect_equal(learner$lags, 1:3)
})

test_that("ForecastLearner lags active binding", {
  learner = ForecastLearner$new(lrn("regr.rpart"), lags = 1:5)
  expect_equal(learner$lags, 1:5)

  graph = po("colapply", applicator = as.numeric) %>>% lrn("regr.rpart")
  learner = expect_warning(ForecastLearner$new(graph), "recursive")
  expect_null(learner$lags)
})
