test_that("partition two way split", {
  task = tsk("airpassengers")
  li = partition(task, ratio = 0.67)
  expect_list(li, len = 3L)
  expect_names(names(li), identical.to = c("train", "test", "validation"))
  expect_equal(length(li$train) + length(li$test) + length(li$validation), task$nrow)
  expect_length(li$validation, 0L)
  expect_disjunct(li$train, li$test)
})

test_that("partition three way split", {
  task = tsk("airpassengers")
  li = partition(task, ratio = c(0.6, 0.2))
  expect_list(li, len = 3L)
  expect_names(names(li), identical.to = c("train", "test", "validation"))
  expect_equal(length(li$train) + length(li$test) + length(li$validation), task$nrow)
  expect_disjunct(li$train, li$test)
  expect_disjunct(li$train, li$validation)
  expect_disjunct(li$test, li$validation)
})

test_that("partition preserves temporal order", {
  task = tsk("airpassengers")
  li = partition(task, ratio = 0.67)
  expect_true(max(li$train) < min(li$test))
})

test_that("partition works with keyed task", {
  b = as_data_backend(load_dataset("Orange", "datasets"))
  task = TaskFcst$new(id = "orange", backend = b, target = "circumference", order = "age", key = "Tree")
  li = partition(task, ratio = 0.67)
  expect_list(li, len = 3L)
  expect_names(names(li), identical.to = c("train", "test", "validation"))
  expect_equal(length(li$train) + length(li$test) + length(li$validation), task$nrow)
  expect_length(li$validation, 0L)
  expect_disjunct(li$train, li$test)
})
