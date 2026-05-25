test_that("DirectForecaster basic train/predict works", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  learner = DirectForecaster$new(
    lrn("regr.rpart"),
    lags = 1:3,
    horizons = length(split$test)
  )

  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("DirectForecaster predictions differ across horizons", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  learner = DirectForecaster$new(
    lrn("regr.rpart", minsplit = 2L, cp = 0),
    lags = 1:3,
    horizons = length(split$test)
  )

  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_false(length(unique(prediction$response)) == 1L)
})

test_that("DirectForecaster works with keyed task", {
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  split = partition(task, ratio = 0.99)
  key = task$col_roles$key
  test_dt = task$data(rows = split$test, cols = c(key, task$col_roles$order))
  test_dt[, "..step" := seq_len(.N), by = key]
  max_step = max(test_dt[["..step"]])
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = max_step)

  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("DirectForecaster errors when test extends past trained horizons", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 2)
  learner$train(task, split$train)
  expect_error(learner$predict(task, split$test), "not trained")
})

test_that("DirectForecaster scalar horizon expands to 1:H", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 5)
  expect_equal(learner$horizons, 1:5)
})

test_that("as_learner_fcst dispatches on strategy", {
  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3, strategy = "direct", horizons = 3)
  expect_class(learner, "DirectForecaster")

  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3)
  expect_class(learner, "RecursiveForecaster")

  learner = as_learner_fcst(lrn("regr.rpart"), lags = 1:3, strategy = "recursive")
  expect_class(learner, "RecursiveForecaster")
})

test_that("as_learner_fcst rejects mismatched horizons and strategy", {
  expect_snapshot(
    as_learner_fcst(lrn("regr.rpart"), lags = 1:3, strategy = "direct"),
    error = TRUE
  )
  expect_snapshot(
    as_learner_fcst(lrn("regr.rpart"), lags = 1:3, horizons = 3),
    error = TRUE
  )
})

test_that("DirectForecaster aligns row_ids and extras when storage order differs from (key, order)", {
  dt = rbindlist(list(
    data.table(
      state = factor("B", levels = c("A", "B")),
      month = as.Date("2020-01-01") + 30 * (0:5),
      y = 100 + 0:5
    ),
    data.table(
      state = factor("A", levels = c("A", "B")),
      month = as.Date("2020-01-01") + 30 * (0:5),
      y = 500 + 0:5
    )
  ))
  task = as_task_fcst(dt, target = "y", order = "month", key = "state", freq = "month")
  train_ids = c(1:4, 7:10)
  test_ids = c(5:6, 11:12)

  flrn = DirectForecaster$new(lrn("regr.rpart", minsplit = 2L, cp = 0), lags = 1L, horizons = 2L)
  flrn$train(task, train_ids)
  pred = as.data.table(flrn$predict(task, test_ids))

  truth_by_row = task$data(rows = pred$row_ids, cols = "y")[[1L]]
  expect_equal(pred$truth, truth_by_row)
  state_by_row = task$data(rows = pred$row_ids, cols = "state")[[1L]]
  expect_equal(pred$state, state_by_row)
})

test_that("DirectForecaster predict_type propagates to trained models", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)

  flrn = DirectForecaster$new(lrn("regr.featureless"), lags = 1:3, horizons = length(split$test))
  flrn$train(task, split$train)
  flrn$predict_type = "se"

  expect_equal(flrn$predict_type, "se")
  expect_all_equal(map_chr(flrn$model$models, "predict_type"), "se")

  pred = flrn$predict(task, split$test)
  expect_false(allMissing(pred$se))
})

test_that("DirectForecaster errors on PipeOpFcstLags inside the graph", {
  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  expect_snapshot(DirectForecaster$new(graph, lags = 1:3, horizons = 3), error = TRUE)
})

test_that("DirectForecaster active bindings", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:5, horizons = 3)
  expect_equal(learner$lags, 1:5)
  expect_equal(learner$horizons, 1:3)
})
