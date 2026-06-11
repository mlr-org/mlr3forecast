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

test_that("asymmetric quantile prediction works", {
  task = tsk("airpassengers")
  learner = quantile_learner(c(0.1, 0.25, 0.9))
  learner$train(task, 1:132)
  pred = learner$predict_newdata(generate_newdata(task, n = 6L))
  q = pred$data$quantiles
  expect_matrix(q, nrows = 6L)
  expect_all_true(!apply(q, 1L, is.unsorted))

  ref = quantile_learner(c(0.1, 0.9))
  ref$train(task, 1:132)
  qref = ref$predict_newdata(generate_newdata(task, n = 6L))$data$quantiles
  expect_equal(q[, "q0.1"], qref[, "q0.1"])
  expect_equal(q[, "q0.9"], qref[, "q0.9"])
})

test_that("quantile prediction with only the median works", {
  task = tsk("airpassengers")
  learner = quantile_learner(0.5)
  learner$train(task, 1:132)
  pred = learner$predict_newdata(generate_newdata(task, n = 3L))
  expect_matrix(pred$data$quantiles, nrows = 3L, ncols = 1L)
})
