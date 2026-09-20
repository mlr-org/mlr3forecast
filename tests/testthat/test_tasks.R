test_that("airpassengers task", {
  task = tsk("airpassengers")
  expect_task(task)
})

test_that("monash task", {
  local_mocked_bindings(
    download_monash_dataset = function(dataset) {
      file = system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast")
      read_tsf(file)
    },
    .package = "mlr3forecast"
  )

  task = tsk("monash", dataset = "m3_yearly")
  expect_task(task)
  expect_identical(task$id, "m3_yearly")
  expect_identical(task$label, "M3 Yearly")
  expect_identical(task$man, "mlr3forecast::mlr_tasks_monash")
  expect_identical(tsk("monash", dataset = "m3_yearly", id = "custom")$id, "custom")
  expect_error(tsk("monash", dataset = "bitcoin_with_missing_values"), class = "Mlr3ErrorInput")
  expect_error(tsk("monash"), class = "missingDefaultError")
  expect_true("monash" %in% mlr_tasks$keys())
  expect_null(tryCatch(mlr_tasks$get("monash"), missingDefaultError = function(e) NULL))
})

test_that("usaccdeaths task", {
  task = tsk("usaccdeaths")
  expect_task(task)
})

test_that("lynx task", {
  task = tsk("lynx")
  expect_task(task)
})

test_that("electricity task", {
  skip_if_not_installed("tsibbledata")

  task = tsk("electricity")
  expect_task(task)
})

test_that("livestock task", {
  skip_if_not_installed("tsibbledata")
  skip_if_not_installed("tsibble")

  task = tsk("livestock")
  expect_task(task)
})
