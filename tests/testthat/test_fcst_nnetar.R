skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.nnetar")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("parallel training works with set_threads", {
  skip_if_not_installed("nnet")
  task = tsk("airpassengers")$filter(1:72)
  learner = set_threads(lrn("fcst.nnetar", p = 2L, size = 1L, repeats = 2L), 2L)
  # the learner must load nnet so predict.nnet is registered on the master,
  # else forecast's parallel path fails during fitted value computation
  expect_subset("nnet", learner$packages)
  learner$train(task)
  response = learner$predict_newdata(generate_newdata(task, n = 3L))$response
  expect_numeric(response, any.missing = FALSE, len = 3L)
})

test_that("quantile prediction enables prediction intervals", {
  withr::local_seed(42)
  task = tsk("airpassengers")
  learner = lrn("fcst.nnetar", repeats = 1L, npaths = 20L)
  learner$predict_type = "quantiles"
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  learner$train(task, 1:132)

  train_task = task$clone()$filter(1:132)
  quantiles = learner$predict_newdata(generate_newdata(train_task, n = 3L))$quantiles
  expect_matrix(quantiles, nrows = 3L, ncols = 3L)
  expect_all_true(!apply(quantiles, 1L, is.unsorted))
})
