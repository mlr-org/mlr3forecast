skip_if_not_installed("forecast")

quantile_learner = function(quantiles) {
  learner = lrn("fcst.arima")
  learner$predict_type = "quantiles"
  learner$quantiles = quantiles
  learner$quantile_response = 0.5
  learner
}

test_that("symmetric quantile prediction works for h = 1 and h > 1", {
  task = tsk("airpassengers")
  learner = quantile_learner(c(0.05, 0.1, 0.9, 0.95))
  learner$train(task, 1:132)

  pred1 = learner$predict_newdata(generate_newdata(task, n = 1L))
  expect_matrix(pred1$data$quantiles, nrows = 1L)

  pred6 = learner$predict_newdata(generate_newdata(task, n = 6L))
  expect_matrix(pred6$data$quantiles, nrows = 6L)
})

test_that("asymmetric quantiles raise a clear error", {
  task = tsk("airpassengers")
  learner = quantile_learner(c(0.1, 0.25, 0.9))
  learner$train(task, 1:132)
  expect_snapshot(learner$predict_newdata(generate_newdata(task, n = 6L)), error = TRUE)
})
