skip_if_not_installed("forecTheta")

test_that("forecasts reuse fitted theta parameters", {
  task = tsk("airpassengers")
  train_task = task$clone()$filter(1:132)
  newdata = generate_newdata(train_task, n = 12L)
  y = as.ts(train_task)

  for (id in c("dotm", "dstm", "otm", "stm")) {
    learner = lrn(paste0("fcst.", id))$train(train_task)
    response = learner$predict_newdata(newdata)$response
    expected = getExportedValue("forecTheta", id)(y, h = 12L, level = NULL)$mean
    expect_equal(response, as.numeric(expected), tolerance = 1e-3, info = id)
    expect_equal(learner$predict(train_task)$response, as.numeric(learner$native_model$fitted), info = id)
    expect_false(any(startsWith(names(learner$native_model), "mlr3_")), info = id)
  }

  learner = lrn("fcst.stheta")$train(train_task)
  response = learner$predict_newdata(newdata)$response
  expect_equal(response, as.numeric(forecTheta::stheta(y, h = 12L)$mean))
  expect_equal(learner$predict(train_task)$response, as.numeric(learner$native_model$fitted))
})

test_that("theta fitted values return to the original scale", {
  task = tsk("airpassengers")$filter(1:132)
  for (id in c("dotm", "dstm", "otm", "stm")) {
    learner = lrn(paste0("fcst.", id), lambda = 0)$train(task)
    expected = exp(as.numeric(learner$native_model$fitted))
    expect_equal(learner$predict(task)$response, expected, info = id)
  }
})

test_that("optimized theta learners support quantiles", {
  task = tsk("airpassengers")$filter(1:132)
  learner = lrn("fcst.otm")
  learner$predict_type = "quantiles"
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  learner$train(task)

  quantiles = with_seed(1L, learner$predict_newdata(generate_newdata(task, n = 2L))$quantiles)
  expect_matrix(quantiles, nrows = 2L, ncols = 3L)
  expect_all_true(apply(quantiles, 1L, function(x) !is.unsorted(x)))
})

test_that("dotm and otm support exogenous features", {
  set.seed(1L)
  data = data.table(
    y = 2 + 0.1 * seq_len(40L) + rnorm(40L),
    x = rnorm(40L),
    date = seq(as.Date("2020-01-01"), by = "day", length.out = 40L)
  )
  task = as_task_fcst(data, target = "y", order = "date")
  train_task = task$clone()$filter(1:35)
  y = as.ts(train_task)
  xreg = matrix(data$x, ncol = 1L)

  for (id in c("dotm", "otm")) {
    learner = lrn(paste0("fcst.", id))$train(task, 1:35)
    response = learner$predict(task, 36:40)$response
    expected = getExportedValue("forecTheta", id)(y, h = 5L, level = NULL, xreg = xreg)$mean
    expect_equal(response, as.numeric(expected), tolerance = 1e-6, info = id)
  }
})
