test_that("PipeOpTargetTrafoScale standardizes with mean and standard deviation", {
  task = tsk("airpassengers")
  po = po("fcst.targetscale")

  out_train = po$train(list(task))$output
  y = as.numeric(task$truth())
  expect_equal(po$state$center, mean(y))
  expect_equal(po$state$scale, sd(y))
  scaled_col = out_train$target_names[1L]
  expect_equal(out_train$data()[[scaled_col]], (y - mean(y)) / sd(y))
})

test_that("PipeOpTargetTrafoScale round-trips", {
  task = tsk("airpassengers")
  po = po("fcst.targetscale")
  po$train(list(task))

  out_predict = po$predict(list(task))
  scaled_col = out_predict$output$target_names[1L]
  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = out_predict$output$data()[[scaled_col]]
  )
  inverted = out_predict$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("targetscale robust variant uses median and mad", {
  task = tsk("airpassengers")
  po = po("fcst.targetscale", robust = TRUE)

  out_train = po$train(list(task))$output
  y = as.numeric(task$truth())
  expect_equal(po$state$center, median(y))
  expect_equal(po$state$scale, mad(y))
  scaled_col = out_train$target_names[1L]
  expect_equal(out_train$data()[[scaled_col]], (y - median(y)) / mad(y))
})

test_that("targetscale respects center and scale switches", {
  task = tsk("airpassengers")
  y = as.numeric(task$truth())

  po_center = po("fcst.targetscale", scale = FALSE)
  out = po_center$train(list(task))$output
  expect_equal(po_center$state$scale, 1)
  expect_equal(out$data()[[out$target_names[1L]]], y - mean(y))

  po_scale = po("fcst.targetscale", center = FALSE)
  out = po_scale$train(list(task))$output
  expect_equal(po_scale$state$center, 0)
  # without centering the denominator is the root-mean-square, not the standard deviation
  rms = sqrt(sum(y^2) / (length(y) - 1L))
  expect_equal(out$data()[[out$target_names[1L]]], y / rms)
})

test_that("targetscale leaves constant series unscaled", {
  data = data.table(idx = 1:20, y = 5)
  task = TaskFcst$new("const", as_data_backend(data), target = "y", order = "idx")
  po = po("fcst.targetscale")
  po$train(list(task))
  expect_equal(po$state$center, 5)
  expect_equal(po$state$scale, 1)

  out_predict = po$predict(list(task))
  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = out_predict$output$data()[[out_predict$output$target_names[1L]]]
  )
  inverted = out_predict$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("targetscale inverts quantile predictions pointwise without crossing", {
  task = tsk("airpassengers")
  po = po("fcst.targetscale")
  po$train(list(task))

  y = as.numeric(task$truth())
  transformed = (y - mean(y)) / sd(y)
  qmat = cbind(transformed - 0.01, transformed, transformed + 0.01)
  setattr(qmat, "probs", c(0.25, 0.5, 0.75))
  setattr(qmat, "response", 0.5)
  prediction = PredictionRegr$new(row_ids = task$row_ids, truth = task$truth(), quantiles = qmat)

  inverted = po$predict(list(task))$fun(list(prediction))[[1L]]
  q = inverted$data$quantiles
  expect_false(is.null(q))
  expect_equal(attr(q, "probs"), c(0.25, 0.5, 0.75))
  # the response quantile (0.5) is the untouched transformed target -> exact round trip
  expect_equal(inverted$response, as.numeric(task$truth()))
  expect_true(all(q[, 1L] <= q[, 2L] & q[, 2L] <= q[, 3L]))
})

test_that("targetscale computes separate statistics per series", {
  task = make_monthly_panel_task()
  po = po("fcst.targetscale")
  po$train(list(task))
  stats = po$state$stats
  expect_data_table(stats, nrows = 2L)
  dt = task$data(cols = c("id", "y"))
  for (series in c("a", "b")) {
    y = dt[list(series), "y", on = "id"][[1L]]
    expect_equal(stats[list(series), "center", on = "id"][[1L]], mean(y))
    expect_equal(stats[list(series), "scale", on = "id"][[1L]], sd(y))
  }
  expect_false(isTRUE(all.equal(stats$center[1L], stats$center[2L])))
})

test_that("targetscale round-trips on a keyed task", {
  task = make_monthly_panel_task()
  po = po("fcst.targetscale")
  po$train(list(task))
  out_predict = po$predict(list(task))
  scaled_col = out_predict$output$target_names[1L]
  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = out_predict$output$data()[[scaled_col]]
  )
  inverted = out_predict$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("targetscale handles multi-column key labels containing the separator", {
  task = make_colon_key_panel_task()
  po = po("fcst.targetscale")
  po$train(list(task))
  out_predict = po$predict(list(task))
  scaled_col = out_predict$output$target_names[1L]
  prediction = PredictionRegr$new(
    row_ids = task$row_ids,
    truth = task$truth(),
    response = out_predict$output$data()[[scaled_col]]
  )
  inverted = out_predict$fun(list(prediction))[[1L]]
  expect_equal(inverted$response, as.numeric(task$truth()))
})

test_that("targetscale inverts keyed quantile predictions with each series' statistics", {
  task = make_monthly_panel_task()
  po = po("fcst.targetscale")
  po$train(list(task))
  out_predict = po$predict(list(task))
  transformed = out_predict$output$data()[[out_predict$output$target_names[1L]]]
  qmat = cbind(transformed - 0.01, transformed, transformed + 0.01)
  setattr(qmat, "probs", c(0.25, 0.5, 0.75))
  setattr(qmat, "response", 0.5)
  prediction = PredictionRegr$new(row_ids = task$row_ids, truth = task$truth(), quantiles = qmat)

  inverted = out_predict$fun(list(prediction))[[1L]]
  q = inverted$data$quantiles
  expect_equal(attr(q, "probs"), c(0.25, 0.5, 0.75))
  # only inverting each row with its own series' statistics recovers the original scale exactly
  expect_equal(inverted$response, as.numeric(task$truth()))
  expect_true(all(q[, 1L] <= q[, 2L] & q[, 2L] <= q[, 3L]))
})

test_that("targetscale errors on key groups not seen during training", {
  task = make_monthly_panel_task()
  train_task = task$clone()$filter(task$row_ids[task$data(cols = "id")$id == "a"])
  po = po("fcst.targetscale")
  po$train(list(train_task))
  expect_error(po$predict(list(task)), "not seen during training")
})

test_that("targetscale + fcst.lags + learner trains and predicts inside a graph", {
  task = tsk("airpassengers")
  inner = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  graph = ppl("targettrafo", graph = inner, trafo_pipeop = po("fcst.targetscale"))

  split = partition(task, ratio = 0.8)
  glrn = as_learner(graph)
  glrn$train(task$clone()$filter(split$train))
  expect_no_error(glrn$predict(task$clone()$filter(split$test)))
})

test_that("targetscale works wrapping DirectForecaster on a keyed task", {
  task = make_monthly_panel_task()
  split = partition(task, ratio = 0.9)
  key = task$col_roles$key
  test_dt = task$data(rows = split$test, cols = c(key, task$col_roles$order))
  test_dt[, "..step" := seq_len(.N), by = key]
  flrn = as_learner(ppl(
    "targettrafo",
    graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = max(test_dt$..step)),
    trafo_pipeop = po("fcst.targetscale")
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)
  expect_r6_class(prediction, "PredictionFcst")
  expect_length(prediction$response, length(split$test))
  expect_false(anyNA(prediction$response))
  expect_equal(nrow(prediction$order), length(split$test))
})

test_that("targetscale works wrapping RecursiveForecaster on a keyed task", {
  task = make_monthly_panel_task()
  split = partition(task, ratio = 0.9)
  flrn = as_learner(ppl(
    "targettrafo",
    graph = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3),
    trafo_pipeop = po("fcst.targetscale")
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)
  expect_r6_class(prediction, "PredictionFcst")
  expect_length(prediction$response, length(split$test))
  expect_false(anyNA(prediction$response))
  expect_equal(prediction$truth, task$truth(prediction$row_ids))
})

test_that("targetscale keeps truth aligned when predict rows are not in time order", {
  task = tsk("airpassengers")
  flrn = as_learner(ppl(
    "targettrafo",
    graph = RecursiveForecaster$new(lrn("regr.featureless"), lags = 1:3),
    trafo_pipeop = po("fcst.targetscale")
  ))
  flrn$train(task, 1:132)
  prediction = flrn$predict(task, rev(133:144))
  expect_equal(prediction$truth, task$truth(prediction$row_ids))
})

test_that("targetscale works wrapping DirectForecaster", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  flrn = as_learner(ppl(
    "targettrafo",
    graph = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test)),
    trafo_pipeop = po("fcst.targetscale")
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)
  expect_r6_class(prediction, "PredictionFcst")
  expect_length(prediction$response, length(split$test))
  expect_false(anyNA(prediction$response))
  # inversion keeps the forecast time index so $order/autoplot/fcstavg work downstream
  expect_equal(nrow(prediction$order), length(split$test))
})
