skip_if_not_installed("setartree")

test_that("autotest", {
  learner = lrn("fcst.setartree")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.setartree")
  expect_true(
    run_paramtest(learner, setartree::setartree, tag = "train", exclude = c("data", "label", "categorical_covariates"))
  )
})

test_that("response and quantile prediction work", {
  task = tsk("airpassengers")
  learner = lrn("fcst.setartree", lag = 12L)
  learner$train(task, 1:132)
  expect_class(learner$native_model, "setartree")

  response = learner$predict(task, 133:144)$response
  expect_numeric(response, finite = TRUE, any.missing = FALSE, len = 12L)

  learner$predict_type = "quantiles"
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  quantiles = learner$predict(task, 133:144)$quantiles
  expect_matrix(quantiles, nrows = 12L, ncols = 3L)
  expect_equal(quantiles[, 2L], response)
  expect_all_true(quantiles[, 1L] < quantiles[, 2L])
  expect_all_true(quantiles[, 2L] < quantiles[, 3L])
})

test_that("in-sample prediction is not supported", {
  task = tsk("airpassengers")
  learner = lrn("fcst.setartree")
  learner$train(task, 1:132)
  expect_error(learner$predict(task, 1:12), "not supported")
})
