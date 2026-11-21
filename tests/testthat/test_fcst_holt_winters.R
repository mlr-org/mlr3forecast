skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.holt_winters")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("in-sample prediction returns one-step fitted values", {
  task = tsk("airpassengers")
  learner = lrn("fcst.holt_winters")
  learner$train(task)
  pred = learner$predict(task, 13:144)
  expect_identical(pred$response, as.numeric(learner$native_model$fitted[, "xhat"]))
  # no fitted values exist before the first complete seasonal cycle
  pred = learner$predict(task)
  expect_identical(pred$response[1:12], rep(NA_real_, 12L))
})

test_that("quantiles match the prediction intervals when the median is requested", {
  task = tsk("airpassengers")
  learner = lrn("fcst.holt_winters", predict_type = "quantiles")
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  learner$train(task, 1:132)
  quantiles = learner$predict(task, 133:144)$quantiles
  fc = forecast::forecast(learner$native_model, h = 12L, level = 80)
  expect_equal(quantiles[, 1L], as.numeric(fc$lower))
  expect_equal(quantiles[, 2L], as.numeric(fc$mean), tolerance = 1e-6)
  expect_equal(quantiles[, 3L], as.numeric(fc$upper))
})
