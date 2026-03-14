test_that("autoplot.TaskFcst works", {
  skip_if_not_installed("vdiffr")
  task = tsk("airpassengers")
  p = autoplot(task)
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("taskfcst_default", p)
})

test_that("autoplot.TaskFcst works with custom theme", {
  skip_if_not_installed("vdiffr")
  task = tsk("airpassengers")
  p = autoplot(task, theme = ggplot2::theme_bw())
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("taskfcst_theme_bw", p)
})
