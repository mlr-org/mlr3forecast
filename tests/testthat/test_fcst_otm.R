skip_if_not_installed("forecTheta")

test_that("autotest", {
  learner = lrn("fcst.otm")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.otm")
  exclude = c("y", "h", "level", "estimation", "xreg", "s", "period")
  expect_true(run_paramtest(learner, forecTheta::otm, tag = "train", exclude = exclude))
})

test_that("predicts a single step of a seasonal series", {
  task = make_forec_theta_task()
  learner = lrn("fcst.otm")$train(task, 1:96)
  expect_length(learner$predict(task, 97L)$response, 1L)
  learner = lrn("fcst.otm", predict_type = "quantiles", quantiles = c(0.1, 0.5, 0.9), quantile_response = 0.5)
  learner$train(task, 1:96)
  expect_identical(dim(learner$predict(task, 97L)$quantiles), c(1L, 3L))
  task$select("x")
  learner = lrn("fcst.otm")$train(task, 1:96)
  expect_length(learner$predict(task, 97L)$response, 1L)
})
