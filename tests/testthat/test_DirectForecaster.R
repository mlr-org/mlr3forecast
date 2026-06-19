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
  expect_error(learner$predict(task, split$test), "beyond the trained horizon")
})

test_that("DirectForecaster scalar horizon expands to 1:H", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 5)
  expect_equal(learner$horizons, 1:5)
})

test_that("DirectForecaster routes specific (non-contiguous) horizons by step-distance", {
  task = tsk("airpassengers")
  n = task$nrow
  train_ids = seq_len(n - 6L)
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = c(2L, 4L, 6L))
  learner$train(task, train_ids)
  expect_length(learner$model$models, 3L)

  test_ids = train_ids[length(train_ids)] + c(2L, 4L, 6L)
  prediction = learner$predict(task, test_ids)
  expect_length(prediction$response, 3L)
  expect_false(anyNA(prediction$response))

  expect_error(
    learner$predict(task, train_ids[length(train_ids)] + 3L),
    "step\\(s\\) 3 which were not trained"
  )
})

test_that("DirectForecaster forecast() matches in-backend predict", {
  task = tsk("airpassengers")
  flrn = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 12L)
  flrn$train(task, 1:132)

  p_backend = flrn$predict(task, 133:144)
  p_newdata = forecast(flrn, task$clone()$filter(1:132), h = 12L)
  expect_equal(p_newdata$response, p_backend$response)
})

test_that("DirectForecaster predict_newdata() matches in-backend predict for sparse horizons", {
  task = tsk("airpassengers")
  train_ids = seq_len(task$nrow - 6L)
  flrn = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = c(2L, 4L, 6L))
  flrn$train(task, train_ids)

  p_backend = flrn$predict(task, max(train_ids) + c(2L, 4L, 6L))
  train_task = task$clone()$filter(train_ids)
  newdata = generate_newdata(train_task, 6L)[c(2L, 4L, 6L)]
  p_newdata = flrn$predict_newdata(newdata, train_task)
  expect_equal(p_newdata$response, p_backend$response)
})

test_that("DirectForecaster forecast() matches in-backend predict on keyed task", {
  task = make_date_major_panel_task(10L)
  flrn = DirectForecaster$new(lrn("regr.rpart", minsplit = 2L, cp = 0), lags = 1:2, horizons = 2L)
  flrn$train(task, 1:16)

  p_backend = as.data.table(flrn$predict(task, 17:20))
  p_newdata = as.data.table(forecast(flrn, task$clone()$filter(1:16), h = 2L))
  setorderv(p_backend, c("id", "date"))
  setorderv(p_newdata, c("id", "date"))
  expect_equal(p_newdata$response, p_backend$response)
})

test_that("direct_forecaster helper works", {
  learner = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = 3)
  expect_class(learner, "DirectForecaster")
  expect_equal(learner$lags, 1:3)
  expect_equal(learner$horizons, 1:3)
})

test_that("DirectForecaster aligns row_ids and extras when storage order differs from (key, order)", {
  dt = rbindlist(list(
    data.table(
      state = factor("B", levels = c("A", "B")),
      month = seq(as.Date("2020-01-01"), by = "month", length.out = 6L),
      y = 100 + 0:5
    ),
    data.table(
      state = factor("A", levels = c("A", "B")),
      month = seq(as.Date("2020-01-01"), by = "month", length.out = 6L),
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

test_that("DirectForecaster errors on fcst.targetdiff inside the graph", {
  graph = ppl("targettrafo", graph = lrn("regr.rpart"), trafo_pipeop = po("fcst.targetdiff", lag = 1L))
  expect_snapshot(DirectForecaster$new(graph, lags = 1:3, horizons = 3), error = TRUE)
})

test_that("DirectForecaster wrapped in a target trafo inverts cumulatively", {
  dt = data.table(y = as.numeric(1:60), date = seq(as.Date("2020-01-01"), by = "day", length.out = 60L))
  task = TaskFcst$new("trend", as_data_backend(dt), target = "y", order = "date", freq = "day")
  flrn = as_learner(ppl(
    "targettrafo",
    graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 5L),
    trafo_pipeop = po("fcst.targetdiff", lag = 1L)
  ))
  flrn$train(task, 1:55)
  expect_equal(flrn$predict(task, 56:60)$response, as.numeric(56:60))
})

test_that("DirectForecaster errors on iterative feature PipeOps inside the graph", {
  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  expect_snapshot(DirectForecaster$new(graph, lags = 1:3, horizons = 3), error = TRUE)

  graph = po("fcst.rolling", funs = "mean", window_sizes = 6L) %>>% lrn("regr.rpart")
  expect_snapshot(DirectForecaster$new(graph, lags = 1:3, horizons = 3), error = TRUE)
})

test_that("DirectForecaster active bindings", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:5, horizons = 3)
  expect_equal(learner$lags, 1:5)
  expect_equal(learner$horizons, 1:3)
})

test_that("DirectForecaster exposes tunable lags in param_set", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 3)
  expect_subset(c("lags", "regr.rpart.cp"), learner$param_set$ids())
  expect_equal(learner$param_set$values$lags, 1:3)

  learner$param_set$values$lags = 1:2
  expect_equal(learner$lags, 1:2)

  learner$train(tsk("airpassengers"), 1:100)
  offsets = map(learner$model$models, function(m) m$graph$pipeops$fcst.lags$param_set$values$lags)
  expect_equal(offsets, list(1:2, 2:3, 3:4))
})

test_that("DirectForecaster batched predict aligns response and se with row order", {
  task = tsk("airpassengers")
  train_ids = 1:132
  flrn = DirectForecaster$new(lrn("regr.featureless", predict_type = "se"), lags = 1:3, horizons = 12L)
  flrn$train(task, train_ids)

  test_ids = sample(133:144)
  pred = flrn$predict(task, test_ids)
  dt = as.data.table(pred)
  expect_equal(dt$row_ids, task$row_ids[match(test_ids, task$row_ids)])
  expect_false(anyNA(pred$response))
  expect_false(anyNA(pred$se))
})

test_that("DirectForecaster clone has independent lags", {
  learner = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = 3)
  clone = learner$clone(deep = TRUE)
  clone$param_set$values$lags = 5:7
  expect_equal(clone$lags, 5:7)
  expect_equal(learner$lags, 1:3)
})

test_that("DirectForecaster native_model returns one fitted model per horizon", {
  task = tsk("airpassengers")
  learner = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = c(1L, 3L, 6L))
  expect_null(learner$native_model)
  learner$train(task)
  nm = learner$native_model
  expect_names(names(nm), identical.to = c("h1", "h3", "h6"))
  expect_r6_class(learner$model$models[[1L]], "GraphLearner")
  expect_class(nm$h1, "rpart")
})

test_that("DirectForecaster model prints a compact summary", {
  task = tsk("airpassengers")
  learner = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = 3L)$train(task)
  out = capture.output(print(learner$model))
  expect_lte(length(out), 6L)
  expect_match(out, "direct_forecaster_model", all = FALSE)
  expect_match(out, "Horizon models: 3", all = FALSE, fixed = TRUE)
})
