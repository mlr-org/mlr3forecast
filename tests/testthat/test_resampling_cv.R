test_that("fcst.cv basic properties", {
  resampling = rsmp(
    "fcst.cv",
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

test_that("fcst.cv works", {
  task = tsk("airpassengers")
  resampling = rsmp("fcst.cv", folds = 3L, horizon = 3L, window_size = 5L, fixed_window = FALSE)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:139)
  expect_identical(resampling$train_set(2L), 1:140)
  expect_identical(resampling$train_set(3L), 1:141)
  expect_identical(resampling$test_set(1L), 140:142)
  walk(1:3, function(i) expect_length(resampling$test_set(i), 3L))

  resampling = rsmp("fcst.cv", folds = 3L, horizon = 5L, window_size = 25L, fixed_window = TRUE)
  resampling$instantiate(task)
  walk(1:3, function(i) expect_length(resampling$train_set(i), 25L))
  walk(1:3, function(i) expect_length(resampling$test_set(i), 5L))
  walk(0:2, function(i) expect_identical(resampling$train_set(i + 1L), (113L + i):(137L + i)))
})

test_that("fcst.cv fixed vs. expanding window", {
  task = tsk("airpassengers")
  task$filter(1:30)

  # fixed window
  resampling = rsmp("fcst.cv", folds = 3L, horizon = 3L, window_size = 5L, fixed_window = TRUE)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 21:25)
  expect_identical(resampling$train_set(2L), 22:26)
  expect_identical(resampling$train_set(3L), 23:27)

  # expanding window
  resampling = rsmp("fcst.cv", folds = 3L, horizon = 3L, window_size = 5L, fixed_window = FALSE)
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:25)
  expect_identical(resampling$train_set(2L), 1:26)
  expect_identical(resampling$train_set(3L), 1:27)
})

test_that("fcst.cv keyed task contains all groups per fold", {
  b = as_data_backend(load_dataset("Orange", "datasets"))
  task = TaskFcst$new(id = "orange", backend = b, target = "circumference", order = "age", key = "Tree")
  n_groups = uniqueN(task$data(cols = "Tree")[[1L]])

  resampling = rsmp("fcst.cv", folds = 3L, horizon = 2L, window_size = 3L, fixed_window = FALSE)
  resampling$instantiate(task)
  expect_identical(resampling$iters, 3L)

  # each fold must contain data from ALL groups
  all_ids = task$row_ids
  walk(seq_len(resampling$iters), function(i) {
    train = resampling$train_set(i)
    test = resampling$test_set(i)
    # test set size = horizon * n_groups
    expect_length(test, 2L * n_groups)
    # train/test disjoint
    expect_identical(intersect(train, test), integer())
    # all ids come from valid row ids
    expect_true(all(train %in% all_ids))
    expect_true(all(test %in% all_ids))
  })
})

test_that("fcst.cv parameter validation", {
  task = tsk("airpassengers")
  task$filter(1:10)

  # window_size + horizon > n
  resampling = rsmp("fcst.cv", folds = 1L, horizon = 5L, window_size = 8L, fixed_window = TRUE)
  expect_error(resampling$instantiate(task), "window_size \\+ horizon")

  # folds exceeds maximum feasible count
  resampling = rsmp("fcst.cv", folds = 10L, horizon = 2L, window_size = 3L, fixed_window = TRUE)
  expect_error(resampling$instantiate(task), "folds.*exceeds the maximum feasible")
})

test_that("fcst.cv with various parameter combinations", {
  task = tsk("airpassengers")
  task$filter(1:30)

  # small window, large step size
  resampling = rsmp(
    "fcst.cv",
    folds = 5L,
    horizon = 2L,
    window_size = 3L,
    step_size = 2L,
    fixed_window = TRUE
  )
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 18:20)
  expect_identical(resampling$test_set(1L), 21:22)
  expect_identical(resampling$train_set(2L), 20:22)
  expect_identical(resampling$test_set(2L), 23:24)
  expect_identical(resampling$train_set(3L), 22:24)
  expect_identical(resampling$test_set(3L), 25:26)

  # large window, small horizon
  resampling = rsmp(
    "fcst.cv",
    folds = 4L,
    horizon = 1L,
    window_size = 10L,
    step_size = 1L,
    fixed_window = FALSE
  )
  resampling$instantiate(task)
  expect_identical(resampling$train_set(1L), 1:26)
  expect_identical(resampling$test_set(1L), 27L)
  expect_identical(resampling$train_set(2L), 1:27)
  expect_identical(resampling$test_set(2L), 28L)
  expect_identical(resampling$train_set(3L), 1:28)
  expect_identical(resampling$test_set(3L), 29L)
  expect_identical(resampling$train_set(4L), 1:29)
  expect_identical(resampling$test_set(4L), 30L)
})
