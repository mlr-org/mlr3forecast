skip_if_not_installed("forecTheta")

test_that("autotest", {
  learner = lrn("fcst.stheta")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.stheta")
  expect_true(run_paramtest(learner, forecTheta::stheta, tag = "train", exclude = c("y", "h", "s", "period")))
})

test_that("predicts a single step of a seasonal series", {
  task = make_forec_theta_task()
  task$select(character())
  learner = lrn("fcst.stheta")$train(task, 1:96)
  expect_length(learner$predict(task, 97L)$response, 1L)
})
