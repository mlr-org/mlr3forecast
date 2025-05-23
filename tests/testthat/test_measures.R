test_that("forecast measures", {
  skip("the assertion in the score method of the measure won't allow for fcst learner")
  keys = mlr_measures$keys("^fcst\\.")
  task = tsk("airpassengers")
  learner = lrn("fcst.auto_arima")
  p = learner$train(task)$predict(task)

  for (key in keys) {
    m = mlr_measures$get(key)
    if (is.na(m$task_type) || m$task_type == "regr") {
      perf = m$score(prediction = p, task = task, learner = learner)
      expect_number(perf, na.ok = FALSE, lower = m$range[1L], upper = m$range[2L])
    }
  }
})

test_that("MeasureMDA works", {
  measure = msr("fcst.mda")
  truth = c(0, 5)
  response = c(1, 6)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 1.0))
  response = c(2, -2)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 0.0))
  # returns 1 when all directions are correct
  truth = 0:10
  response = truth + 2
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 1.0))
  # returns 0.5 when half the directions are correct
  truth = 1:5
  response = rev(truth)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 0.5))
  # returns 0 when all directions are wrong
  truth = 1:5
  response = truth - 1L
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 0.0))
  # returns 1 for constant series
  truth = response = rep(7, 5)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 1.0))
})

test_that("MeasureMDV works", {
  measure = msr("fcst.mdv")
  # returns +1 when all directions are correct
  truth = 0:10
  response = truth + 2
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdv = 1.0))
  # returns –1 when all directions are wrong
  truth = 0:10
  response = truth - 1L
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdv = -1.0))
  # returns 0 for constant series
  truth = response = rep(7, 5)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdv = 0.0))
})

test_that("MeasureMDPV works", {
  measure = msr("fcst.mdpv")
  # returns +100 when all directions are correct
  truth = c(1, 2, 4, 8, 16)
  response = truth + 1L
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdpv = 1.0))
  # returns –100 when all directions are wrong
  response = rep(0, length(truth))
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdpv = -1.0))
  # returns 0 for constant series
  truth = response = rep(7, 5)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdpv = 0.0))
})
