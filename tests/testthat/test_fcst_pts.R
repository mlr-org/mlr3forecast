skip_if_not_installed("muse")

test_that("autotest", {
  learner = lrn("fcst.pts")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.pts")
  exclude = c("data", "formula", "h", "holdout", "componentVariance", "period")
  expect_true(run_paramtest(learner, muse::pts, tag = "train", exclude = exclude))
})

test_that("forecasts match a direct pts call", {
  task = tsk("airpassengers")
  learner = lrn("fcst.pts", model = "0LT")$train(task, 1:132)
  response = learner$predict_newdata(generate_newdata(task$clone()$filter(1:132), n = 12L))$response
  fit = muse::pts(as.ts(task$clone()$filter(1:132)), model = "0LT")
  expect_identical(response, as.numeric(generics::forecast(fit, h = 12L)$mean))
})

test_that("the median quantile equals the point forecast", {
  task = tsk("airpassengers")
  learner = lrn("fcst.pts", predict_type = "quantiles", quantiles = c(0.1, 0.5, 0.9), quantile_response = 0.5)
  learner$train(task, 1:132)
  newdata = generate_newdata(task$clone()$filter(1:132), n = 3L)
  quantiles = learner$predict_newdata(newdata)$quantiles
  expect_true(all(quantiles[, 1L] < quantiles[, 2L] & quantiles[, 2L] < quantiles[, 3L]))
  learner$predict_type = "response"
  expect_equal(quantiles[, 2L], learner$predict_newdata(newdata)$response, tolerance = 1e-6)
})
