test_that("fcst task generators are registered", {
  keys = as.data.table(mlr_task_generators)[task_type == "fcst", key]
  expect_identical(keys, "arima")

  for (key in keys) {
    generator = tgen(key)
    expect_task_generator(generator)
    n = 30L
    task = generator$generate(n)
    expect_task(task)
    expect_class(task, "TaskFcst")
    expect_identical(task$task_type, "fcst")
    expect_identical(task$nrow, n)
    expect_identical(task$id, sprintf("%s_%i", key, n))
    expect_identical(task$target_names, "y")
    expect_identical(task$col_roles$order, "time")
    expect_identical(task$col_roles$key, character())
    expect_identical(task$freq, "month")
  }
})
