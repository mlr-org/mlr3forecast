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

test_that("autoplot.PredictionFcst draws the forecast region only", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("rpart")
  p = fcst_prediction()
  g = ggplot2::autoplot(p)
  expect_s3_class(g, "ggplot")
  vdiffr::expect_doppelganger("predictionfcst_forecast_only", g)
})

test_that("autoplot.PredictionFcst overlays history from task", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("rpart")
  task = tsk("airpassengers")
  p = fcst_prediction(task)
  g = ggplot2::autoplot(p, task = task)
  expect_s3_class(g, "ggplot")
  expect_subset("colour", names(g$mapping))
  vdiffr::expect_doppelganger("predictionfcst_with_history", g)
})

test_that("autoplot.PredictionFcst works with custom theme", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("rpart")
  task = tsk("airpassengers")
  p = fcst_prediction(task)
  g = ggplot2::autoplot(p, task = task, theme = ggplot2::theme_bw())
  expect_s3_class(g, "ggplot")
  vdiffr::expect_doppelganger("predictionfcst_theme_bw", g)
})

test_that("autoplot.PredictionFcst colours one line per series for keyed tasks", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("tsibbledata")
  skip_if_not_installed("rpart")
  task = tsk("livestock")
  p = fcst_prediction(task)
  g = ggplot2::autoplot(p, task = task)
  expect_s3_class(g, "ggplot")
  expect_subset("colour", names(g$mapping))
  vdiffr::expect_doppelganger("predictionfcst_keyed", g)
})

test_that("autoplot.PredictionFcst facets one panel per series", {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("tsibbledata")
  skip_if_not_installed("rpart")
  task = tsk("livestock")
  p = fcst_prediction(task)
  g = ggplot2::autoplot(p, task = task, facets = TRUE)
  expect_s3_class(g, "ggplot")
  expect_s3_class(g$facet, "FacetWrap")
  vdiffr::expect_doppelganger("predictionfcst_facets", g)
})

test_that("autoplot.PredictionFcst rejects non-flag facets", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("rpart")
  p = fcst_prediction()
  expect_snapshot(ggplot2::autoplot(p, facets = "yes"), error = TRUE)
})

test_that("autoplot.PredictionFcst draws interval ribbons for quantile forecasts", {
  skip_if_not_installed("vdiffr")
  p = make_quantile_prediction()
  g = ggplot2::autoplot(p)
  expect_s3_class(g, "ggplot")
  expect_s3_class(g$layers[[1L]]$geom, "GeomRibbon")
  expect_setequal(g$layers[[1L]]$data$.level, c(80, 90))
  vdiffr::expect_doppelganger("predictionfcst_quantiles", g)
})

test_that("autoplot.PredictionFcst draws interval ribbons over the history overlay", {
  skip_if_not_installed("vdiffr")
  task = tsk("airpassengers")
  p = make_quantile_prediction()
  g = ggplot2::autoplot(p, task = task)
  expect_s3_class(g, "ggplot")
  expect_s3_class(g$layers[[1L]]$geom, "GeomRibbon")
  vdiffr::expect_doppelganger("predictionfcst_quantiles_history", g)
})

test_that("autoplot.PredictionFcst skips quantiles without a symmetric partner", {
  skip_if_not_installed("ggplot2")
  p = make_quantile_prediction(probs = c(0.1, 0.5))
  g = ggplot2::autoplot(p)
  expect_length(g$layers, 1L)
  expect_s3_class(g$layers[[1L]]$geom, "GeomLine")
})

test_that("autoplot.PredictionFcst errors without a time index and without task", {
  skip_if_not_installed("ggplot2")
  p = PredictionFcst$new(row_ids = 1:3, truth = c(1, 2, 3), response = c(1, 2, 3))
  expect_snapshot(ggplot2::autoplot(p), error = TRUE)
})
