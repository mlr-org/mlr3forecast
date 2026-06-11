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
