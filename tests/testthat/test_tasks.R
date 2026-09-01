test_that("airpassengers task", {
  task = tsk("airpassengers")
  expect_task(task)
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
