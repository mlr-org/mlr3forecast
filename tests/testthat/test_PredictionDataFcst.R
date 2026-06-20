test_that("as_prediction round-trips PredictionDataFcst", {
  skip_if_not_installed("rpart")
  p = fcst_prediction()
  expect_s3_class(p$data, "PredictionDataFcst")
  p2 = as_prediction(p$data)
  expect_r6_class(p2, "PredictionFcst")
})

test_that("c.PredictionDataFcst keeps class and extra data", {
  skip_if_not_installed("rpart")
  task = tsk("airpassengers")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  pdata = learner$predict(task, split$test)$data

  combined = c(pdata, pdata, keep_duplicates = TRUE)
  expect_s3_class(combined, "PredictionDataFcst")
  expect_false(is.null(combined$extra))
  expect_length(combined$row_ids, 2L * length(pdata$row_ids))
})

test_that("filter_prediction_data.PredictionDataFcst keeps class and filters extra", {
  skip_if_not_installed("rpart")
  task = tsk("airpassengers")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  pdata = learner$predict(task, split$test)$data

  keep = pdata$row_ids[1:3]
  filtered = filter_prediction_data(pdata, keep)
  expect_s3_class(filtered, "PredictionDataFcst")
  expect_equal(filtered$row_ids, keep)
  expect_length(filtered$extra[[1L]], 3L)
})

test_that("is_missing_prediction_data.PredictionDataFcst flags NA responses", {
  p = PredictionFcst$new(row_ids = 1:3, truth = c(1, 2, 3), response = c(1, NA, 3))
  expect_equal(is_missing_prediction_data(p$data), 2L)
})
