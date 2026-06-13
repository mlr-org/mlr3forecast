test_that("PipeOpTargetTrafoBoxCox round-trip with fixed lambda", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  po = po("fcst.targetboxcox", lambda = 0.5)

  out_train = po$train(list(task))
  expect_equal(nrow(out_train$output$data()), task$nrow)

  out_predict = po$predict(list(task))
  bc_col = out_predict$output$target_names[1L]
  bc_pred = out_predict$output$data()[[bc_col]]

  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = bc_pred
  )
  inverted = out_predict$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("PipeOpTargetTrafoBoxCox with lambda = 0 is the log transform", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  po = po("fcst.targetboxcox", lambda = 0)

  out_predict = po$train(list(task))$output
  bc_col = out_predict$target_names[1L]
  expect_equal(out_predict$data()[[bc_col]], log(as.numeric(task$truth())))

  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = out_predict$data()[[bc_col]]
  )
  inverted = po$predict(list(task))$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("PipeOpTargetTrafoBoxCox estimates lambda within bounds and round-trips", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  po = po("fcst.targetboxcox", lower = -1, upper = 2)

  out_predict = po$train(list(task))$output
  lambda = po$state$lambda
  expect_number(lambda, lower = -1, upper = 2, finite = TRUE)

  bc_col = po$predict(list(task))$output$target_names[1L]
  bc_pred = po$predict(list(task))$output$data()[[bc_col]]
  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = bc_pred
  )
  inverted = po$predict(list(task))$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("targetboxcox + fcst.lags + learner trains and predicts inside a graph", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  inner = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  graph = ppl("targettrafo", graph = inner, trafo_pipeop = po("fcst.targetboxcox"))

  split = partition(task, ratio = 0.8)
  glrn = as_learner(graph)
  glrn$train(task$clone()$filter(split$train))
  expect_no_error(glrn$predict(task$clone()$filter(split$test)))
})

test_that("targetboxcox works wrapping DirectForecaster", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  flrn = as_learner(ppl(
    "targettrafo",
    graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
    trafo_pipeop = po("fcst.targetboxcox")
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)
  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
  expect_false(anyNA(prediction$response))
})
