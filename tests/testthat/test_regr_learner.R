skip_if_not_installed(c("mlr3learners", "ranger", "dplyr"))

test_that("autotest", {
  fcst_dat = tsk("airpassengers")$data() |>
    dplyr::mutate(month = as.numeric(month))
  fcst_tsk = as_task_fcst(
    fcst_dat,
    target = "passengers",
    order = "month",
    freq = "monthly"
  )
  learner = lrn("regr.ranger")

  learner$train(fcst_tsk)
  expect_no_error(learner$predict(fcst_tsk))

  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})
