test_that("forecast measures", {
  keys = mlr_measures$keys("^fcst\\.")
  task = tsk("california_housing")
  learner = lrn("regr.rpart")
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
  response = frev(truth)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 0.5))
  # returns 0 when all directions are wrong
  truth = 1:5
  response = truth - 1L
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mda = 0.0))
  # returns 1 for constant series
  truth = response = rep.int(7, 5)
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
  truth = response = rep.int(7, 5)
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
  response = rep.int(0, length(truth))
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdpv = -1.0))
  # returns 0 for constant series
  truth = response = rep.int(7, 5)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mdpv = 0.0))
})

test_that("MeasureMPE works", {
  measure = msr("fcst.mpe")
  # perfect forecast
  truth = c(10, 20, 30)
  pred = PredictionRegr$new(truth = truth, response = truth, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mpe = 0.0))
  # under-forecasting gives positive MPE
  response = c(8, 16, 24)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_true(unname(pred$score(measure)) > 0)
  # over-forecasting gives negative MPE
  response = c(12, 24, 36)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_true(unname(pred$score(measure)) < 0)
})

test_that("MeasureACF1 works", {
  measure = msr("fcst.acf1")
  # non-trivial residuals produce a value in [-1, 1]
  truth = c(10, 12, 11, 15, 13, 18, 16)
  response = c(10.5, 11.5, 12, 14, 14, 17, 15)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_number(unname(pred$score(measure)), lower = -1, upper = 1)
  # single observation returns NA
  pred = PredictionRegr$new(truth = 1, response = 1, row_ids = 1L)
  expect_identical(unname(pred$score(measure)), NA_real_)
})

test_that("measures match fabletools reference implementation", {
  skip_if_not_installed("fabletools")

  truth = c(10, 12, 11, 15, 13, 18, 16)
  response = c(10.5, 11.5, 12, 14, 14, 17, 15)
  resid = truth - response
  row_ids = seq_along(truth)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = row_ids)

  # MDA
  expected_mda = fabletools::MDA(resid, truth)
  expect_equal(unname(pred$score(msr("fcst.mda"))), expected_mda)

  # MDA with custom reward/penalty
  expected_mda_custom = fabletools::MDA(resid, truth, reward = 1, penalty = -1)
  expect_equal(
    unname(pred$score(msr("fcst.mda", reward = 1, penalty = -1))),
    expected_mda_custom
  )

  # MDV
  expected_mdv = fabletools::MDV(resid, truth)
  expect_equal(unname(pred$score(msr("fcst.mdv"))), expected_mdv)

  # MPE
  expected_mpe = fabletools::MPE(resid, truth)
  expect_equal(unname(pred$score(msr("fcst.mpe"))), expected_mpe)

  # ACF1
  expected_acf1 = fabletools::ACF1(resid)
  expect_equal(unname(pred$score(msr("fcst.acf1"))), expected_acf1)
})
