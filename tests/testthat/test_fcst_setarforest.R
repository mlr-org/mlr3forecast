skip_if_not_installed("setartree")

test_that("autotest", {
  learner = lrn("fcst.setarforest")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.setarforest")
  expect_true(
    run_paramtest(learner, setartree::setarforest, tag = "train", exclude = c("data", "label", "categorical_covariates"))
  )
})

test_that("response and quantile prediction work", {
  task = tsk("airpassengers")
  learner = lrn("fcst.setarforest", lag = 12L, bagging_freq = 3L)
  learner$train(task, 1:132)
  expect_class(learner$native_model, "setarforest")

  response = learner$predict(task, 133:144)$response
  expect_numeric(response, finite = TRUE, any.missing = FALSE, len = 12L)

  learner$predict_type = "quantiles"
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  quantiles = learner$predict(task, 133:144)$quantiles
  expect_matrix(quantiles, nrows = 12L, ncols = 3L)
  expect_all_true(apply(quantiles, 1L, function(x) !is.unsorted(x)))
})

test_that("training keeps the global rng state", {
  task = tsk("airpassengers")
  learner = lrn("fcst.setarforest", bagging_freq = 2L)
  withr::local_seed(1L)
  seed = .Random.seed
  learner$train(task, 1:132)
  expect_identical(.Random.seed, seed)
})

test_that("set_threads sets num_cores", {
  learner = set_threads(lrn("fcst.setarforest"), 2L)
  expect_identical(learner$param_set$values$num_cores, 2L)
})
