skip_if_not_installed("forecast")

test_that("in-sample predictions align for training windows not anchored at row 1", {
  task = tsk("airpassengers")
  learner = lrn("fcst.random_walk")
  learner$train(task, 50:144)

  # naive fitted values are the lagged series, so alignment is directly checkable
  pred_tail = learner$predict(task, 140:144)
  expect_equal(pred_tail$response, as.numeric(task$truth(139:143)))

  pred_mid = learner$predict(task, 60:70)
  expect_equal(pred_mid$response, as.numeric(task$truth(59:69)))
})

test_that("in-sample subsets without the last training timestamp are not misrouted", {
  task = tsk("airpassengers")
  learner = lrn("fcst.random_walk")
  learner$train(task, 1:132)
  pred = learner$predict(task, 60:70)
  expect_equal(pred$response, as.numeric(task$truth(59:69)))
})

test_that("predict errors on mixed in-sample and future rows", {
  task = tsk("airpassengers")
  learner = lrn("fcst.random_walk")
  learner$train(task, 1:132)
  expect_snapshot(learner$predict(task, 130:135), error = TRUE)
})

test_that("in-sample predict errors for rows before the training window", {
  task = tsk("airpassengers")
  learner = lrn("fcst.random_walk")
  learner$train(task, 50:144)
  expect_snapshot(learner$predict(task, 10:20), error = TRUE)
})

test_that("in-sample routing survives callr encapsulation", {
  skip_if_not_installed("callr")
  task = tsk("airpassengers")
  learner = lrn("fcst.random_walk")
  learner$encapsulate("callr", lrn("fcst.mean"))
  learner$train(task, 50:144)
  pred = learner$predict(task, 60:70)
  expect_equal(pred$response, as.numeric(task$truth(59:69)))
})
