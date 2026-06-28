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

test_that("training is invariant to backend row order", {
  withr::local_seed(1)
  n = 30L
  dat = data.table(t = 1:n, y = as.numeric(1:n))
  sorted = as_task_fcst(dat, target = "y", order = "t")
  shuffled = as_task_fcst(dat[sample(n)], target = "y", order = "t")

  # as.ts reads the target chronologically regardless of backend row order
  expect_identical(as.numeric(as.ts(shuffled)), as.numeric(as.ts(sorted)))

  # full learner: the naive forecast is the last chronological value
  f_sorted = lrn("fcst.random_walk")$train(sorted)$predict_newdata(generate_newdata(sorted, 1L), sorted)
  f_shuffled = lrn("fcst.random_walk")$train(shuffled)$predict_newdata(generate_newdata(shuffled, 1L), shuffled)
  expect_equal(f_shuffled$response, f_sorted$response)
  expect_equal(f_shuffled$response, dat$y[n])
})

test_that("in-sample prediction is invariant to backend row order", {
  withr::local_seed(1)
  n = 48L
  y = 10 + 0.3 * (1:n) + 5 * sin(2 * pi * (1:n) / 12) + rnorm(n, 0, 0.2)
  dat = data.table(t = 1:n, y = y)
  sorted = as_task_fcst(dat, target = "y", order = "t", freq = 12)
  shuffled = as_task_fcst(dat[sample(n)], target = "y", order = "t", freq = 12)

  # in-sample fitted values must follow each row's timestamp, not the backend layout
  insample = function(task) {
    pred = lrn("fcst.ets")$train(task)$predict(task)
    t = as.numeric(task$data(rows = pred$row_ids, cols = "t")[[1L]])
    data.table(t = t, response = pred$response)[order(t)]
  }
  expect_equal(insample(shuffled)$response, insample(sorted)$response)
})

test_that("predict rejects future rows that are not in chronological order", {
  withr::local_seed(1)
  n = 36L
  dat = data.table(t = 1:n, y = as.numeric(1:n))
  task = as_task_fcst(dat, target = "y", order = "t")
  learner = lrn("fcst.ets")$train(task)
  newdata = generate_newdata(task, 6L)

  expect_silent(learner$predict_newdata(newdata, task))
  expect_error(learner$predict_newdata(newdata[c(4, 1, 6, 2, 5, 3)], task), "chronological order")
})

test_that("exogenous features stay aligned with the target under backend reordering", {
  withr::local_seed(42)
  n = 40L
  x = rnorm(n)
  dat = data.table(t = 1:n, x = x, y = 3 + 2 * x + rnorm(n, 0, 0.01))
  sorted = as_task_fcst(dat, target = "y", order = "t")
  shuffled = as_task_fcst(dat[sample(n)], target = "y", order = "t")

  # x is uncorrelated with time, so a misaligned xreg would collapse its coefficient
  learner = lrn("fcst.tslm", formula = y ~ x)
  c_sorted = coef(learner$clone()$train(sorted)$native_model)
  c_shuffled = coef(learner$clone()$train(shuffled)$native_model)
  expect_equal(c_shuffled, c_sorted)
  expect_equal(unname(c_shuffled[["x"]]), 2, tolerance = 0.05)
})
