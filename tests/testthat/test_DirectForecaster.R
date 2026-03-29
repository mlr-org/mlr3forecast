test_that("DirectForecaster basic train/predict works", {
  task = tsk("airpassengers")
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("DirectForecaster predictions differ across horizons", {
  task = tsk("airpassengers")
  learner = DirectForecaster$new(lrn("regr.rpart", minsplit = 2L, cp = 0), lags = 1:3, horizons = 3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_false(length(unique(prediction$response)) == 1L)
})

test_that("DirectForecaster works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("DirectForecaster scalar horizon expands to 1:H", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 5)
  expect_equal(learner$horizons, 1:5)
})

test_that("as_learner_fcst dispatches on horizons", {
  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3, horizons = 3)
  expect_class(learner, "DirectForecaster")

  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  expect_class(learner, "ForecastLearner")
})

test_that("DirectForecaster active bindings", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:5, horizons = 3)
  expect_equal(learner$lags, 1:5)
  expect_equal(learner$horizons, 1:3)
})
