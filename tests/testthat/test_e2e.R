# end-to-end smoke tests covering scoring, resampling, benchmarking, and tuning
# for both classical (stats) and ML forecasting learners

lgr::get_logger("mlr3")$set_threshold("warn")
lgr::get_logger("bbotk")$set_threshold("warn")

test_that("stats forecaster: train + predict + score", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  flrn = lrn("fcst.arima")$train(task, split$train)
  pred = flrn$predict(task, split$test)
  expect_number(pred$score(msr("regr.rmse")), lower = 0, finite = TRUE)
})

test_that("stats forecaster: resample + aggregate", {
  skip_if_not_installed("forecast")
  rr = resample(tsk("airpassengers"), lrn("fcst.arima"), rsmp("fcst.holdout", ratio = 0.8))
  expect_number(rr$aggregate(msr("regr.rmse")), lower = 0, finite = TRUE)
})

test_that("RecursiveForecaster: train + predict + score", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)$train(task, split$train)
  pred = flrn$predict(task, split$test)
  expect_number(pred$score(msr("regr.rmse")), lower = 0, finite = TRUE)
})

test_that("DirectForecaster: train + predict + score", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.8)
  flrn = direct_forecaster(
    lrn("regr.rpart"),
    lags = 1:3,
    horizons = length(split$test)
  )$train(task, split$train)
  pred = flrn$predict(task, split$test)
  expect_number(pred$score(msr("regr.rmse")), lower = 0, finite = TRUE)
})

test_that("ML forecasters: resample + aggregate", {
  task = tsk("airpassengers")
  flrns = list(
    recursive = recursive_forecaster(lrn("regr.rpart"), lags = 1:3),
    direct = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = 29)
  )
  for (flrn in flrns) {
    rr = resample(task, flrn, rsmp("fcst.holdout", ratio = 0.8))
    expect_number(rr$aggregate(msr("regr.rmse")), lower = 0, finite = TRUE)
  }
})

test_that("benchmark across stats and ML forecasters in one design", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  learners = list(
    lrn("fcst.arima"),
    recursive_forecaster(lrn("regr.rpart"), lags = 1:3),
    direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = 29)
  )
  design = benchmark_grid(task, learners, rsmp("fcst.holdout", ratio = 0.8))
  bmr = benchmark(design)
  scores = bmr$aggregate(msr("regr.rmse"))
  expect_equal(nrow(scores), 3L)
  expect_numeric(scores$regr.rmse, lower = 0, finite = TRUE, any.missing = FALSE, len = 3L)
})

test_that("AutoTuner on stats forecaster (fcst.arima)", {
  skip_on_cran()
  skip_if_not_installed("forecast")
  skip_if_not_installed("mlr3tuning")
  library(mlr3tuning)
  flrn = lrn("fcst.arima")
  flrn$param_set$set_values(include.drift = to_tune(p_lgl()))
  at = AutoTuner$new(
    learner = flrn,
    resampling = rsmp("fcst.holdout", ratio = 0.8),
    measure = msr("regr.rmse"),
    terminator = trm("evals", n_evals = 2),
    tuner = tnr("random_search")
  )
  at$train(tsk("airpassengers"))
  expect_number(at$tuning_result$regr.rmse, lower = 0, finite = TRUE)
})

test_that("AutoTuner on RecursiveForecaster", {
  skip_on_cran()
  skip_if_not_installed("mlr3tuning")
  library(mlr3tuning)
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  flrn$param_set$set_values(regr.rpart.cp = to_tune(0.001, 0.1, logscale = TRUE))
  at = AutoTuner$new(
    learner = flrn,
    resampling = rsmp("fcst.holdout", ratio = 0.8),
    measure = msr("regr.rmse"),
    terminator = trm("evals", n_evals = 3),
    tuner = tnr("random_search")
  )
  at$train(tsk("airpassengers"))
  expect_number(at$tuning_result$regr.rmse, lower = 0, finite = TRUE)
})

test_that("AutoTuner on DirectForecaster", {
  skip_on_cran()
  skip_if_not_installed("mlr3tuning")
  library(mlr3tuning)
  flrn = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = 29)
  flrn$param_set$set_values(regr.rpart.cp = to_tune(0.001, 0.1, logscale = TRUE))
  at = AutoTuner$new(
    learner = flrn,
    resampling = rsmp("fcst.holdout", ratio = 0.8),
    measure = msr("regr.rmse"),
    terminator = trm("evals", n_evals = 3),
    tuner = tnr("random_search")
  )
  at$train(tsk("airpassengers"))
  expect_number(at$tuning_result$regr.rmse, lower = 0, finite = TRUE)
})
