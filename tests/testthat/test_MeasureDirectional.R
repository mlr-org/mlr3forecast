test_that("forecast measures", {
  keys = mlr_measures$keys("^fcst\\.")
  task = tsk("airpassengers")
  learner = lrn("fcst.auto_arima")
  p = learner$train(task)$predict(task)

  for (key in keys) {
    m = mlr_measures$get(key)
    if (is.na(m$task_type) || m$task_type == "regr") {
      perf = m$score(prediction = p, task = task, learner = learner)
      expect_number(perf, na.ok = FALSE, lower = m$range[1], upper = m$range[2])
    }
  }
})
