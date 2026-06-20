test_that("autoplot.TaskFcst works", {
  skip_if_not_installed("vdiffr")
  task = tsk("airpassengers")
  p = ggplot2::autoplot(task)
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("taskfcst_default", p)
})

test_that("autoplot.TaskFcst works with custom theme", {
  skip_if_not_installed("vdiffr")
  task = tsk("airpassengers")
  p = ggplot2::autoplot(task, theme = ggplot2::theme_bw())
  expect_s3_class(p, "ggplot")
  vdiffr::expect_doppelganger("taskfcst_theme_bw", p)
})

test_that("autoplot.TaskFcst colours one line per series for keyed tasks", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  p = ggplot2::autoplot(task)
  expect_s3_class(p, "ggplot")
  expect_subset("colour", names(p$mapping))
  n_series = uniqueN(task$data(cols = task$col_roles$key))
  expect_equal(nlevels(p$data$.key), n_series)
  vdiffr::expect_doppelganger("taskfcst_keyed", p)
})

test_that("autoplot.TaskFcst facets one panel per series", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("tsibbledata")
  task = tsk("livestock")
  p = ggplot2::autoplot(task, facets = TRUE)
  expect_s3_class(p, "ggplot")
  expect_s3_class(p$facet, "FacetWrap")
  expect_disjunct("colour", names(p$mapping))
  vdiffr::expect_doppelganger("taskfcst_facets", p)
})

test_that("autoplot.TaskFcst rejects non-flag facets", {
  skip_if_not_installed("ggplot2")
  expect_snapshot(ggplot2::autoplot(tsk("airpassengers"), facets = "yes"), error = TRUE)
})
