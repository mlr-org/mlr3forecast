skip_if_not_installed("forecast")

test_that("autotest", {
  learner = lrn("fcst.struct_ts")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("in-sample prediction errors informatively", {
  task = tsk("airpassengers")
  learner = lrn("fcst.struct_ts")
  learner$train(task)
  expect_snapshot(learner$predict(task, 100:144), error = TRUE)
})
