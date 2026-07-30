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

test_that("c.PredictionDataFcst rejects different quantile levels", {
  make_pred = function(row_ids, probs) {
    PredictionFcst$new(
      row_ids = row_ids,
      truth = rep(NA_real_, 3L),
      quantiles = make_quantiles(c(0, 1, 2), c(2, 3, 4), probs = probs),
      extra = list(date = seq(as.Date("2020-01-01"), by = "day", length.out = 3L)),
      col_roles = list(order = "date", key = character())
    )
  }
  p1 = make_pred(1:3, probs = c(0.1, 0.9))
  p2 = make_pred(4:6, probs = c(0.25, 0.75))
  expect_error(c(p1$data, p2$data), "different quantile levels")
  expect_silent(c(p1$data, make_pred(4:6, probs = c(0.1, 0.9))$data))
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
  expect_identical(filtered$col_roles, pdata$col_roles)
})

test_that("is_missing_prediction_data.PredictionDataFcst flags NA responses", {
  p = PredictionFcst$new(row_ids = 1:3, truth = c(1, 2, 3), response = c(1, NA, 3))
  expect_equal(is_missing_prediction_data(p$data), 2L)
})

test_that("c.PredictionDataFcst rejects different column roles", {
  make_pred = function(row_ids, key) {
    PredictionFcst$new(
      row_ids = row_ids,
      truth = rep(NA_real_, 2L),
      response = c(1, 2),
      extra = list(date = as.Date("2020-01-01") + 0:1, id = c("a", "a")),
      col_roles = list(order = "date", key = key)
    )
  }

  expect_error(c(make_pred(1:2, "id")$data, make_pred(3:4, character())$data), "different extra column roles")
})

test_that("PredictionDataFcst validates explicit column roles", {
  expect_error(
    PredictionFcst$new(
      row_ids = 1:2,
      truth = rep(NA_real_, 2L),
      response = c(1, 2),
      extra = list(date = as.Date("2020-01-01") + 0:1),
      col_roles = list(order = "date", key = "id")
    ),
    "columns in col_roles"
  )

  expect_error(
    PredictionFcst$new(
      row_ids = 1:2,
      truth = rep(NA_real_, 2L),
      response = c(1, 2),
      extra = list(date = as.Date("2020-01-01") + 0:1),
      col_roles = list(order = "date", key = "date")
    ),
    "both the 'order' and the 'key' role"
  )
})

test_that("col_roles are canonicalized so element order does not matter", {
  make_pred = function(row_ids, col_roles) {
    PredictionFcst$new(
      row_ids = row_ids,
      truth = rep(NA_real_, 2L),
      response = c(1, 2),
      extra = list(date = as.Date("2020-01-01") + 0:1, id = c("a", "a")),
      col_roles = col_roles
    )
  }
  p1 = make_pred(1:2, list(order = "date", key = "id"))
  p2 = make_pred(3:4, list(key = "id", order = "date"))

  expect_identical(p2$data$col_roles, list(order = "date", key = "id"))
  combined = c(p1$data, p2$data)
  expect_identical(combined$col_roles, list(order = "date", key = "id"))
})

test_that("extra columns carry no roles without a task or explicit col_roles", {
  p = PredictionFcst$new(
    row_ids = 1:2,
    truth = rep(NA_real_, 2L),
    response = c(1, 2),
    extra = list(date = as.Date("2020-01-01") + 0:1, id = c("a", "b"))
  )
  expect_identical(p$data$col_roles, list(order = character(), key = character()))
  expect_null(p$order)
  expect_null(p$key)
})

test_that("col_roles derivation tolerates tasks without forecast role slots", {
  pdata = set_class(
    list(
      row_ids = 1:2,
      truth = rep(NA_real_, 2L),
      response = c(1, 2),
      extra = list(date = as.Date("2020-01-01") + 0:1)
    ),
    c("PredictionDataFcst", "PredictionData")
  )
  checked = check_prediction_data(pdata, train_task = tsk("mtcars"))
  expect_identical(checked$col_roles, list(order = character(), key = character()))
})

test_that("stored col_roles win over roles derived from the task", {
  dt = data.table(
    date = rep.int(seq(as.Date("2025-01-01"), length.out = 5L), 2L),
    value = rnorm(10L),
    id = rep(c("a", "b"), each = 5L)
  )
  task = as_task_fcst(dt, target = "value", order = "date", key = "id")

  pdata = set_class(
    list(
      row_ids = 1:2,
      truth = rep(NA_real_, 2L),
      response = c(1, 2),
      extra = list(date = as.Date("2025-01-06") + 0:1, id = c("a", "b")),
      col_roles = list(order = "date", key = character())
    ),
    c("PredictionDataFcst", "PredictionData")
  )
  checked = check_prediction_data(pdata, train_task = task)
  expect_identical(checked$col_roles, list(order = "date", key = character()))
})
