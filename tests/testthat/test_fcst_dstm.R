skip_if_not_installed("forecTheta")

test_that("autotest", {
  learner = lrn("fcst.dstm")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.dstm")
  exclude = c("y", "h", "level", "estimation", "xreg", "s", "period")
  expect_true(run_paramtest(learner, forecTheta::dstm, tag = "train", exclude = exclude))
})

test_that("predicts a single step of a seasonal series", {
  task = make_forec_theta_task()
  task$select(character())
  learner = lrn("fcst.dstm")$train(task, 1:96)
  expect_length(learner$predict(task, 97L)$response, 1L)
  learner = lrn("fcst.dstm", predict_type = "quantiles", quantiles = c(0.1, 0.5, 0.9), quantile_response = 0.5)
  learner$train(task, 1:96)
  expect_identical(dim(learner$predict(task, 97L)$quantiles), c(1L, 3L))
})
