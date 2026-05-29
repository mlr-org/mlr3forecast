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
})
