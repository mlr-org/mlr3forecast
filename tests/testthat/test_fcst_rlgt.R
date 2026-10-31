skip_if_not_installed("Rlgt")

test_that("autotest", {
  learner = lrn("fcst.rlgt")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("quantile prediction returns monotonic bounds", {
  withr::local_seed(1)
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.95)
  learner = lrn("fcst.rlgt", method = "Gibbs", control = Rlgt::rlgt.control(NUM_OF_ITER = 1000))
  learner$predict_type = "quantiles"
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  learner$train(task, split$train)
  pred = learner$predict(task, split$test)
  qs = pred$quantiles
  expect_all_true(qs[, 1L] <= qs[, 2L])
  expect_all_true(qs[, 2L] <= qs[, 3L])
  expect_all_true(qs[, 3L] - qs[, 1L] > 1)
})

test_that("quantile probs mapping to the single interval level 50 work", {
  withr::local_seed(1)
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.95)
  learner = lrn("fcst.rlgt", method = "Gibbs", control = Rlgt::rlgt.control(NUM_OF_ITER = 1000))
  learner$predict_type = "quantiles"
  # quartiles map to the single level 50, which Rlgt special-cases
  learner$quantiles = c(0.25, 0.5, 0.75)
  learner$quantile_response = 0.5
  learner$train(task, split$train)
  qs = learner$predict(task, split$test)$quantiles
  expect_equal(ncol(qs), 3L)
  expect_equal(nrow(qs), length(split$test))
  expect_all_true(qs[, 1L] <= qs[, 2L])
  expect_all_true(qs[, 2L] <= qs[, 3L])
  expect_all_true(qs[, 3L] - qs[, 1L] > 1)
})

test_that("quantile prediction widens with multiple levels", {
  withr::local_seed(1)
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.95)
  learner = lrn("fcst.rlgt", method = "Gibbs", control = Rlgt::rlgt.control(NUM_OF_ITER = 1000))
  learner$predict_type = "quantiles"
  probs = c(0.025, 0.1, 0.5, 0.9, 0.975)
  learner$quantiles = probs
  learner$quantile_response = 0.5
  learner$train(task, split$train)
  qs = learner$predict(task, split$test)$quantiles
  expect_equal(ncol(qs), length(probs))
  expect_equal(nrow(qs), length(split$test))
  expect_all_true(apply(qs, 1L, function(x) !is.unsorted(x)))
  expect_all_true(qs[, 1L] < qs[, 2L])
  expect_all_true(qs[, 4L] < qs[, 5L])
})

test_that("Gibbs sampling rejects features and Stan-only parameters", {
  dt = data.table(time = 1:30, y = as.numeric(1:30), x = as.numeric(30:1))
  task = as_task_fcst(dt, target = "y", order = "time")
  expect_error(lrn("fcst.rlgt")$train(task), class = "Mlr3ErrorConfig")
  expect_error(lrn("fcst.rlgt", method = "Gibbs")$train(task), class = "Mlr3ErrorConfig")
  expect_error(lrn("fcst.rlgt", level.method = "seasAvg"), "Stan")
  expect_error(lrn("fcst.rlgt", method = "Gibbs", NUM_OF_TRIALS = 100L), "Stan")
  expect_error(lrn("fcst.rlgt", verbose = TRUE), "Stan")
  expect_error(lrn("fcst.rlgt", method = "Stan", seasonality = 12L), "Gibbs")
  expect_error(lrn("fcst.rlgt", method = "Stan", homoscedastic = TRUE), "Gibbs")
})

test_that("Stan sampling uses exogenous features", {
  skip_on_cran()
  withr::local_seed(1)
  dt = data.table(time = 1:40, x = rnorm(40L, 10))
  dt[, y := 50 + 3 * x + rnorm(40L)]
  task = as_task_fcst(dt, target = "y", order = "time")
  control = Rlgt::rlgt.control(NUM_OF_ITER = 500L, MAX_NUM_OF_REPEATS = 1L, NUM_OF_CHAINS = 1L, NUM_OF_CORES = 1L)
  learner = lrn("fcst.rlgt", method = "Stan", NUM_OF_TRIALS = 200L, control = control)
  utils::capture.output(suppressWarnings(learner$train(task, 1:35)))
  newdata = dt[36:40]
  pred = withr::with_seed(1, learner$predict_newdata(newdata, task)$response)
  pred_shifted = withr::with_seed(1, learner$predict_newdata(newdata[, x := x + 10], task)$response)
  expect_gt(mean(pred_shifted - pred), 10)
})
