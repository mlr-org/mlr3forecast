test_that("forecast_cv basic properties", {
  task = tsk("penguins")
  resampling = rsmp("forecast_cv",
    folds = 10L, horizon = 3L, window_size = 5L, fixed_window = FALSE
  )
  expect_resampling(resampling, task)
  resampling$instantiate(task)
  expect_resampling(resampling, task)
  expect_identical(resampling$iters, 10L)
  expect_equal(intersect(resampling$test_set(1L), resampling$train_set(1L)), integer())
  expect_false(resampling$duplicated_ids)
})

test_that("forecast_cv works", {
  skip_if_not_installed("tsbox")
  dt = tsbox::ts_dt(AirPassengers)
  dt[, time := NULL]
  task = as_task_regr(dt, target = "value")

  resampling = rsmp("forecast_cv",
    folds = 3L, horizon = 3L, window_size = 5L, fixed_window = FALSE
  )
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:141)
  expect_identical(resampling$train_set(2L), 1:140)
  expect_identical(resampling$train_set(3L), 1:139)
  expect_identical(resampling$test_set(1L), 142:144)
  walk(1:3, function(i) expect_length(resampling$test_set(i), 3L))

  resampling = rsmp("forecast_cv",
    folds = 3L, horizon = 5L, window_size = 25L, fixed_window = TRUE
  )
  resampling$instantiate(task)
  walk(1:3, function(i) expect_length(resampling$train_set(i), 25L))
  walk(1:3, function(i) expect_length(resampling$test_set(i), 5L))
  walk(0:2, function(i) expect_identical(resampling$train_set(i + 1L), (115L - i):(139L - i)))
})
