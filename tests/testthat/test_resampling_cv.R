test_that("forecast_cv basic properties", {
  resampling = rsmp(
    "forecast_cv",
    folds = 10L,
    horizon = 3L,
    window_size = 5L,
    fixed_window = FALSE
  )

  # task without a key
  task = tsk("airpassengers")
  expect_resampling(resampling, task, strata = FALSE)
  resampling$instantiate(task)
  expect_resampling(resampling, task, strata = FALSE)
  expect_identical(resampling$iters, 10L)
  expect_identical(intersect(resampling$test_set(1L), resampling$train_set(1L)), integer())
  expect_false(resampling$duplicated_ids)

  # task with a key
  task = tsk("livestock")
  expect_resampling(resampling, task, strata = FALSE)
  resampling$instantiate(task)
  expect_resampling(resampling, task, strata = FALSE)
  expect_identical(resampling$iters, 10L)
  expect_identical(intersect(resampling$test_set(1L), resampling$train_set(1L)), integer())
  expect_false(resampling$duplicated_ids)
})

test_that("forecast_cv works", {
  task = tsk("airpassengers")
  resampling = rsmp("forecast_cv", folds = 3L, horizon = 3L, window_size = 5L, fixed_window = FALSE)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:141)
  expect_identical(resampling$train_set(2L), 1:140)
  expect_identical(resampling$train_set(3L), 1:139)
  expect_identical(resampling$test_set(1L), 142:144)
  walk(1:3, function(i) expect_length(resampling$test_set(i), 3L))

  resampling = rsmp("forecast_cv", folds = 3L, horizon = 5L, window_size = 25L, fixed_window = TRUE)
  resampling$instantiate(task)
  walk(1:3, function(i) expect_length(resampling$train_set(i), 25L))
  walk(1:3, function(i) expect_length(resampling$test_set(i), 5L))
  walk(0:2, function(i) expect_identical(resampling$train_set(i + 1L), (115L - i):(139L - i)))
})

test_that("forecast_cv fixed vs. expanding window", {
  task = tsk("airpassengers")
  task$filter(1:30)

  # fixed window
  resampling = rsmp("forecast_cv", folds = 3L, horizon = 3L, window_size = 5L, fixed_window = TRUE)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 23:27)
  expect_identical(resampling$train_set(2L), 22:26)
  expect_identical(resampling$train_set(3L), 21:25)

  # expanding window
  resampling = rsmp("forecast_cv", folds = 3L, horizon = 3L, window_size = 5L, fixed_window = FALSE)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:27)
  expect_identical(resampling$train_set(2L), 1:26)
  expect_identical(resampling$train_set(3L), 1:25)
})

test_that("forecast_cv with various parameter combinations", {
  task = tsk("airpassengers")
  task$filter(1:30)

  # small window, large step size
  resampling = rsmp(
    "forecast_cv",
    folds = 5L,
    horizon = 2L,
    window_size = 3L,
    step_size = 2L,
    fixed_window = TRUE
  )
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 26:28)
  expect_identical(resampling$test_set(1L), 29:30)
  expect_identical(resampling$train_set(2L), 24:26)
  expect_identical(resampling$test_set(2L), 27:28)
  expect_identical(resampling$train_set(3L), 22:24)
  expect_identical(resampling$test_set(3L), 25:26)

  # large window, small horizon
  resampling = rsmp(
    "forecast_cv",
    folds = 4L,
    horizon = 1L,
    window_size = 10L,
    step_size = 1L,
    fixed_window = FALSE
  )
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:29)
  expect_identical(resampling$test_set(1L), 30L)
  expect_identical(resampling$train_set(2L), 1:28)
  expect_identical(resampling$test_set(2L), 29L)
  expect_identical(resampling$train_set(3L), 1:27)
  expect_identical(resampling$test_set(3L), 28L)
  expect_identical(resampling$train_set(4L), 1:26)
  expect_identical(resampling$test_set(4L), 27L)
})
