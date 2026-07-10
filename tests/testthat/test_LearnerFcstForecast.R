skip_if_not_installed("forecast")

quantile_learner = function(quantiles) {
  learner = lrn("fcst.arima")
  learner$predict_type = "quantiles"
  learner$quantiles = quantiles
  learner$quantile_response = 0.5
  learner
}

test_that("quantile prediction errors when quantiles are not set", {
  task = tsk("airpassengers")
  learner = lrn("fcst.arima")
  learner$predict_type = "quantiles"
  learner$train(task, 1:132)
  expect_error(
    learner$predict_newdata(generate_newdata(task, n = 1L)),
    "Quantiles must be set"
  )
})

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

test_that("native model print does not dump the inlined series", {
  task = tsk("airpassengers")
  target = task$target_names

  learner = lrn("fcst.arima")$train(task)
  expect_equal(learner$native_model$series, target)

  learner = lrn("fcst.ets")$train(task)
  call = learner$native_model$call
  expect_equal(call[[1L]], as.name("ets"))
  expect_equal(call$y, as.name(target))

  for (id in c("fcst.arima", "fcst.ets", "fcst.bats", "fcst.nnetar")) {
    out = capture.output(print(lrn(id)$train(task)$native_model))
    expect_all_true(nchar(out) < 120L)
  }
})

test_that("exogenous predict is robust to reordered predict-task features", {
  skip_if_not_installed("forecast")
  withr::local_seed(42)
  n = 60L
  dt = data.table(
    month = seq(as.Date("2020-01-01"), by = "month", length.out = n),
    y = as.numeric(cumsum(rnorm(n))) + 50,
    temp = rnorm(n, 20, 5),
    promo = as.numeric(rbinom(n, 1L, 0.3)) * 100
  )
  set(dt, j = "y", value = dt$y + 2 * dt$temp + 0.5 * dt$promo)
  task = as_task_fcst(dt, target = "y", order = "month", freq = "month")
  split = partition(task, ratio = 0.8)
  learner = lrn("fcst.arima")$train(task, split$train)

  reordered = task$clone()
  reordered$col_roles$feature = rev(task$feature_names)
  expect_equal(
    learner$predict(reordered, split$test)$response,
    learner$predict(task, split$test)$response
  )
})
