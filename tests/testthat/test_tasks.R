test_that("airpassengers task", {
  task = tsk("airpassengers")
  expect_task(task)
})

test_that("electricity task", {
  task = tsk("electricity")
  expect_task(task)
})

test_that("livestock task", {
  task = tsk("livestock")
  expect_task(task)
})
