test_that("forecast_holdout basic properties", {
  task = tsk("penguins")
  resampling = rsmp("forecast_holdout", ratio = 0.7)
  expect_resampling(resampling, task)
  resampling$instantiate(task)
  expect_resampling(resampling, task)
  expect_identical(resampling$iters, 1L)
  expect_equal(intersect(resampling$test_set(1L), resampling$train_set(1L)), integer())
  expect_error(resampling$train_set(2L))
  expect_error(resampling$test_set(2L))
  expect_false(resampling$duplicated_ids)
})

test_that("forecast_holdout works", {
  skip_if_not_installed("tsbox")
  dt = tsbox::ts_dt(AirPassengers)
  dt[, time := NULL]
  task = as_task_regr(dt, target = "value")
  resampling = rsmp("forecast_holdout")
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:115)
  expect_identical(resampling$test_set(1L), 116:144)

  resampling = rsmp("forecast_holdout", ratio = 0.5)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:72)
  expect_identical(resampling$test_set(1L), 73:144)
})
