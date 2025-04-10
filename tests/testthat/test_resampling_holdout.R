test_that("forecast_holdout basic properties", {
  # only work with fcst task
  task = tsk("iris")
  resampling = rsmp("forecast_holdout", ratio = 0.8)
  expect_error(resampling$instantiate(task), "Resampling 'forecast_holdout' requires an ordered task.")

  # mutually exclusive params
  task = tsk("airpassengers")
  resampling = rsmp("forecast_holdout", ratio = 0.8, n = 10L)
  expect_error(resampling$instantiate(task), "Either parameter `ratio` (x)or `n` must be provided", fixed = TRUE)
  resampling = rsmp("forecast_holdout")
  expect_error(resampling$instantiate(task), "Either parameter `ratio` (x)or `n` must be provided", fixed = TRUE)

  # task without a key
  task = tsk("airpassengers")
  resampling = rsmp("forecast_holdout", ratio = 0.8)
  expect_resampling(resampling, task, strata = FALSE)
  resampling$instantiate(task)
  expect_resampling(resampling, task, strata = FALSE)
  expect_identical(resampling$iters, 1L)
  expect_identical(intersect(resampling$test_set(1L), resampling$train_set(1L)), integer())
  expect_error(resampling$train_set(2L))
  expect_error(resampling$test_set(2L))
  expect_false(resampling$duplicated_ids)

  resampling = rsmp("forecast_holdout", ratio = 0.5)$instantiate(task)
  expect_length(resampling$train_set(1L), task$nrow / 2L)
  expect_length(resampling$test_set(1L), task$nrow / 2L)

  resampling = rsmp("forecast_holdout", n = 10L)$instantiate(task)
  expect_length(resampling$train_set(1L), 10L)
  expect_length(resampling$test_set(1L), task$nrow - 10L)

  resampling = rsmp("forecast_holdout", n = -10L)$instantiate(task)
  expect_length(resampling$train_set(1L), task$nrow - 10L)
  expect_length(resampling$test_set(1L), 10L)

  # task with a key
  task = tsk("livestock")
  resampling = rsmp("forecast_holdout", ratio = 0.8)
  expect_resampling(resampling, task, strata = FALSE)
  resampling$instantiate(task)
  expect_resampling(resampling, task, strata = FALSE)
  expect_identical(resampling$iters, 1L)
  expect_identical(intersect(resampling$test_set(1L), resampling$train_set(1L)), integer())
  expect_error(resampling$train_set(2L))
  expect_error(resampling$test_set(2L))
  expect_false(resampling$duplicated_ids)
})

test_that("forecast_holdout works", {
  task = tsk("airpassengers")
  resampling = rsmp("forecast_holdout", ratio = 0.8)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:115)
  expect_identical(resampling$test_set(1L), 116:144)

  resampling = rsmp("forecast_holdout", ratio = 0.5)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:72)
  expect_identical(resampling$test_set(1L), 73:144)
})

test_that("forecast_holdout repeated instantiation", {
  task = tsk("airpassengers")
  resampling = rsmp("forecast_holdout", ratio = 0.6)

  resampling$instantiate(task)
  train_set_1 = resampling$train_set(1L)
  test_set_1 = resampling$test_set(1L)

  resampling$instantiate(task)
  train_set_2 = resampling$train_set(1L)
  test_set_2 = resampling$test_set(1L)

  expect_identical(train_set_1, train_set_2)
  expect_identical(test_set_1, test_set_2)

  resampling$param_set$set_values(ratio = 0.8)
  resampling$instantiate(task)
  expect_false(identical(train_set_1, resampling$train_set(1L)))
  expect_false(identical(test_set_1, resampling$test_set(1L)))
})
