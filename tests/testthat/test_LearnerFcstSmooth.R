skip_if_not_installed("smooth")

test_that("smooth learners use exogenous features", {
  withr::local_seed(1)
  dt = data.table(time = 1:48, y = as.numeric(1:48) + rnorm(48), x = rnorm(48))
  task = as_task_fcst(dt, target = "y", order = "time", freq = 12L)
  split = partition(task, ratio = 0.8)
  ids = c(
    "fcst.adam",
    "fcst.auto_adam",
    "fcst.gum",
    "fcst.auto_gum",
    "fcst.ces",
    "fcst.auto_ces",
    "fcst.msarima",
    "fcst.auto_msarima"
  )
  for (id in ids) {
    learner = lrn(id)
    expect_subset("exogenous", learner$properties, info = id)
    suppressWarnings(learner$train(task, split$train))
    expect_subset("x", names(stats::coef(learner$native_model)), info = id)
    p = suppressWarnings(learner$predict(task, split$test))
    expect_numeric(p$response, any.missing = FALSE, len = length(split$test), info = id)
  }
})

test_that("native model print does not dump the inlined series", {
  task = tsk("airpassengers")
  learner = lrn("fcst.adam")$train(task)
  call = learner$native_model$call
  expect_equal(call[[1L]], as.name("adam"))
  expect_equal(call$data, as.name(task$target_names))
  out = capture.output(print(learner$native_model))
  expect_all_true(nchar(out) < 120L)
})
