skip_if_not_installed("echos")

test_that("autotest", {
  learner = lrn("fcst.esn", n_states = 5L, n_models = 2L, n_initial = 1L, n_diff = 1L)
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.esn")
  expect_true(run_paramtest(learner, echos::train_esn, tag = "train", exclude = "y"))
  expect_true(
    run_paramtest(learner, echos::forecast_esn, tag = "predict", exclude = c("object", "n_ahead", "levels"))
  )
})

test_that("response and quantile prediction work", {
  task = tsk("airpassengers")
  learner = lrn(
    "fcst.esn",
    n_states = 10L,
    n_models = 5L,
    n_initial = 2L,
    n_diff = 1L,
    n_sim = 100L
  )
  learner$train(task, 1:132)
  newdata = generate_newdata(task$clone()$filter(1:132), n = 3L)

  response = learner$predict_newdata(newdata)$response
  expect_numeric(response, any.missing = FALSE, len = 3L)

  learner$predict_type = "quantiles"
  learner$quantiles = c(0.025, 0.1, 0.5, 0.9, 0.975)
  learner$quantile_response = 0.5
  quantiles = learner$predict_newdata(newdata)$quantiles
  expect_matrix(quantiles, nrows = 3L, ncols = 5L)
  expect_all_true(apply(quantiles, 1L, function(x) !is.unsorted(x)))
})

test_that("arbitrary quantile probabilities work", {
  task = tsk("airpassengers")
  learner = lrn("fcst.esn", n_states = 5L, n_models = 2L, n_initial = 1L, n_diff = 1L, n_sim = 50L)
  learner$predict_type = "quantiles"
  learner$quantiles = c(0.123, 0.5, 0.877)
  learner$quantile_response = 0.5
  learner$train(task, 1:132)

  newdata = generate_newdata(task$clone()$filter(1:132), n = 1L)
  quantiles = learner$predict_newdata(newdata)$quantiles
  expect_matrix(quantiles, nrows = 1L, ncols = 3L)
  expect_false(is.unsorted(as.numeric(quantiles)))
})
