skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.snaive")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.snaive")
  expect_true(run_paramtest(learner, forecast::rw_model, tag = "train", exclude = c("y", "lag", "drift", "period")))
})

test_that("forecasts repeat the last season", {
  task = tsk("airpassengers")
  learner = lrn("fcst.snaive")
  learner$train(task, 1:132)
  newdata = generate_newdata(task$clone()$filter(1:132), n = 12L)
  response = learner$predict_newdata(newdata)$response
  y = task$data(cols = task$target_names, ordered = TRUE)[[1L]]
  expect_equal(response, y[121:132])
  expect_equal(response, as.numeric(forecast::snaive(as.ts(task$clone()$filter(1:132)), h = 12L)$mean))
})

test_that("weekly forecasts use a 52-week lag", {
  data = data.table(y = as.numeric(1:160), date = seq(as.Date("2020-01-01"), by = "week", length.out = 160L))
  task = as_task_fcst(data, target = "y", order = "date", freq = "week")
  learner = lrn("fcst.snaive")$train(task)
  expect_equal(learner$predict_newdata(generate_newdata(task, n = 3L))$response, as.numeric(109:111))
})

test_that("the period hyperparameter sets the seasonal lag", {
  task = tsk("airpassengers")
  learner = lrn("fcst.snaive", period = 4)$train(task, 1:132)
  response = learner$predict_newdata(generate_newdata(task$clone()$filter(1:132), n = 4L))$response
  y = task$data(cols = task$target_names, ordered = TRUE)[[1L]]
  expect_equal(response, y[129:132])
})

test_that("quantile prediction works", {
  task = tsk("airpassengers")
  learner = lrn("fcst.snaive")
  learner$predict_type = "quantiles"
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  learner$train(task, 1:132)
  newdata = generate_newdata(task$clone()$filter(1:132), n = 3L)
  quantiles = learner$predict_newdata(newdata)$quantiles
  expect_matrix(quantiles, nrows = 3L, ncols = 3L)
  expect_all_true(apply(quantiles, 1L, function(x) !is.unsorted(x)))
})
