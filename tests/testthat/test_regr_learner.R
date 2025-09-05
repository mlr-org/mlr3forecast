skip_if_not_installed(c("mlr3learners", "ranger"))

test_that("autotest", {
  fcst_tsk = tsk("airpassengers")
  learner = lrn("regr.ranger")

  learner$train(fcst_tsk)
  expect_no_error(learner$predict(fcst_tsk))

  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})
