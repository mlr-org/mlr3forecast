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
