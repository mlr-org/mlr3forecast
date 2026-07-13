test_that("PredictionFcst is a regression prediction carrying the time index", {
  skip_if_not_installed("rpart")
  task = tsk("airpassengers")
  p = fcst_prediction(task, h = 12L)

  expect_r6_class(p, "PredictionFcst")
  expect_r6_class(p, "PredictionRegr")
  expect_equal(p$task_type, "regr")
  expect_data_table(p$order, nrows = 12L)
  expect_named(p$order, c("row_id", "order"))
  expect_null(p$key)
  expect_subset(task$col_roles$order, names(as.data.table(p)))
})

test_that("as.data.table.PredictionFcst leads with the time index", {
  skip_if_not_installed("rpart")
  task = tsk("airpassengers")
  p = fcst_prediction(task, h = 6L)
  tab = as.data.table(p)
  order = task$col_roles$order
  expect_equal(names(tab)[1L], order)
  expect_lt(match(order, names(tab)), match("response", names(tab)))
})

test_that("PredictionFcst$key returns the series identity for keyed tasks", {
  skip_if_not_installed("rpart")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  p = fcst_prediction(task, h = 6L)

  expect_data_table(p$key, nrows = length(p$row_ids))
  expect_subset("row_id", names(p$key))
  expect_data_table(p$order, nrows = length(p$row_ids))
})

test_that("PredictionFcst is scored by regression measures", {
  skip_if_not_installed("rpart")
  task = tsk("airpassengers")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  p = learner$predict(task, split$test)

  expect_r6_class(p, "PredictionFcst")
  expect_number(p$score(msr("regr.rmse")), lower = 0)
})

test_that("PredictionFcst$order and $key are NULL without extra data", {
  p = PredictionFcst$new(row_ids = 1:3, truth = c(1, 2, 3), response = c(1, 2, 3))
  expect_null(p$order)
  expect_null(p$key)
})

test_that("PredictionFcst derives response from quantiles", {
  quantiles = matrix(1:9, nrow = 3L, dimnames = list(NULL, c("q0.1", "q0.5", "q0.9")))
  setattr(quantiles, "probs", c(0.1, 0.5, 0.9))
  setattr(quantiles, "response", 0.5)

  p = PredictionFcst$new(
    row_ids = 1:3,
    truth = 1:3,
    quantiles = quantiles,
    extra = list(date = seq(as.Date("2020-01-01"), by = "day", length.out = 3L))
  )

  expect_equal(p$response, p$data$quantiles[, "q0.5"])
  expect_equal(as.data.table(p)$response, p$data$quantiles[, "q0.5"])
})
