test_that("PipeOpTargetTrafoDifference round-trip with lag = 1", {
  task = tsk("airpassengers")
  po = po("fcst.targetdiff", lag = 1L)

  out_train = po$train(list(task))
  expect_equal(nrow(out_train$output$data()), task$nrow - 1L)

  out_predict = po$predict(list(task))
  diff_col = out_predict$output$target_names[1L]
  diff_pred = out_predict$output$data()[[diff_col]]

  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = diff_pred
  )
  inverted = out_predict$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("PipeOpTargetTrafoDifference round-trip with lag = 12", {
  task = tsk("airpassengers")
  po = po("fcst.targetdiff", lag = 12L)

  po$train(list(task))
  out_predict = po$predict(list(task))
  diff_col = out_predict$output$target_names[1L]
  diff_pred = out_predict$output$data()[[diff_col]]

  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = diff_pred
  )
  inverted = out_predict$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("targetdiff + fcst.lags + learner trains and predicts inside a graph", {
  task = tsk("airpassengers")
  inner = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  graph = ppl("targettrafo", graph = inner, trafo_pipeop = po("fcst.targetdiff", lag = 1L))

  split = partition(task, ratio = 0.8)
  glrn = as_learner(graph)
  glrn$train(task$clone()$filter(split$train))
  expect_no_error(glrn$predict(task$clone()$filter(split$test)))
})

test_that("targetdiff round-trips on a keyed task", {
  task = make_date_major_panel_task()
  for (lag in c(1L, 3L)) {
    op = po("fcst.targetdiff", lag = lag)
    out_train = op$train(list(task))
    expect_equal(nrow(out_train$output$data()), task$nrow - 2L * lag)

    out_predict = op$predict(list(task))
    diff_col = out_predict$output$target_names[1L]
    prediction = PredictionRegr$new(
      row_ids = task$row_ids,
      truth = task$truth(),
      response = out_predict$output$data()[[diff_col]]
    )
    inverted = out_predict$fun(list(prediction))[[1L]]
    expect_equal(inverted$response, as.numeric(task$truth()))
  }
})

test_that("targetdiff differences within each series", {
  task = make_date_major_panel_task()
  op = po("fcst.targetdiff", lag = 1L)
  out_train = op$train(list(task))$output
  diff_col = out_train$target_names[1L]
  # y is a 0/100 offset + rowid(id): a cross-series difference would be around +-100, within-series it is always 1
  expect_equal(unique(out_train$data()[[diff_col]]), 1)
})

test_that("targetdiff stores per-series tails", {
  task = make_date_major_panel_task()
  op = po("fcst.targetdiff", lag = 3L)
  op$train(list(task))
  tails = op$state$tails
  expect_data_table(tails, nrows = 6L)
  expect_equal(tails[list("a"), "y", on = "id"][[1L]], 8:10)
  expect_equal(tails[list("b"), "y", on = "id"][[1L]], 108:110)
})

test_that("targetdiff errors on key groups not seen during training", {
  task = make_date_major_panel_task()
  train_task = task$clone()$filter(task$row_ids[task$data(cols = "id")$id == "a"])
  op = po("fcst.targetdiff", lag = 1L)
  op$train(list(train_task))
  expect_error(op$predict(list(task)), "not seen during training")
})

test_that("targetdiff drops series too short for the lag and rejects them at predict", {
  dates = seq(as.Date("2020-01-01"), by = "day", length.out = 10L)
  data = rbind(
    data.table(date = dates, id = factor("a", levels = c("a", "b")), y = seq_len(10L)),
    data.table(date = dates[1:2], id = factor("b", levels = c("a", "b")), y = 1:2)
  )
  task = TaskFcst$new("panel", as_data_backend(data), target = "y", order = "date", key = "id", freq = "day")
  op = po("fcst.targetdiff", lag = 3L)
  expect_warning(out_train <- op$train(list(task)), "Dropped 1 series")
  expect_equal(out_train$output$nrow, 7L)
  expect_equal(as.character(unique(out_train$output$data(cols = "id")$id)), "a")
  expect_error(op$predict(list(task)), "not seen during training")
})

test_that("targetdiff works wrapping DirectForecaster on a keyed task", {
  task = make_monthly_panel_task()
  split = partition(task, ratio = 0.9)
  key = task$col_roles$key
  test_dt = task$data(rows = split$test, cols = c(key, task$col_roles$order))
  test_dt[, "..step" := seq_len(.N), by = key]
  flrn = as_learner(ppl(
    "targettrafo",
    graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = max(test_dt$..step)),
    trafo_pipeop = po("fcst.targetdiff", lag = 1L)
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)
  expect_class(prediction, "PredictionFcst")
  expect_length(prediction$response, length(split$test))
  expect_false(anyNA(prediction$response))
  expect_equal(nrow(prediction$key), length(split$test))
})

test_that("targetdiff works wrapping RecursiveForecaster on a keyed task", {
  task = make_monthly_panel_task()
  split = partition(task, ratio = 0.9)
  flrn = as_learner(ppl(
    "targettrafo",
    graph = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3),
    trafo_pipeop = po("fcst.targetdiff", lag = 1L)
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)
  expect_length(prediction$response, length(split$test))
  expect_false(anyNA(prediction$response))
})

test_that("targetdiff works wrapping DirectForecaster", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  flrn = as_learner(ppl(
    "targettrafo",
    graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
    trafo_pipeop = po("fcst.targetdiff", lag = 1L)
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)
  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
  expect_false(anyNA(prediction$response))
})
