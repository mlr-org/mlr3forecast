test_that("PipeOpFcstAvg keeps PredictionFcst and infers fcst task_type", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  graph = gunion(list(
    po("learner", lrn("fcst.ets"), id = "ets"),
    po("learner", lrn("fcst.theta"), id = "theta")
  )) %>>%
    po("fcst.regravg")
  glrn = as_learner(graph)
  expect_equal(glrn$task_type, "fcst")

  glrn$train(task)
  p = forecast(glrn, task, 6L)
  expect_r6_class(p, "PredictionFcst")
  expect_equal(nrow(p$order), 6L)
})

test_that("PipeOpFcstAvg response is the row-wise weighted average", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  l1 = lrn("fcst.ets")
  l2 = lrn("fcst.theta")
  graph = gunion(list(
    po("learner", l1$clone(), id = "ets"),
    po("learner", l2$clone(), id = "theta")
  )) %>>%
    po("fcst.regravg")

  p = forecast(as_learner(graph)$train(task), task, 6L)
  p1 = forecast(l1$clone()$train(task), task, 6L)
  p2 = forecast(l2$clone()$train(task), task, 6L)
  expect_equal(p$response, (p1$response + p2$response) / 2)
})

test_that("PipeOpFcstAvg preserves keys for multi-series tasks", {
  dt = rbind(
    data.table(series = "a", t = as.Date("2020-01-01") + 0:23, y = as.numeric(1:24)),
    data.table(series = "b", t = as.Date("2020-01-01") + 0:23, y = as.numeric(24:1))
  )
  dt[, series := as.factor(series)]
  task = as_task_fcst(dt, target = "y", order = "t", key = "series", freq = "day")
  fg = po("fcst.lags", lags = 1:3) %>>% lrn("regr.featureless")
  graph = gunion(list(
    po("learner", recursive_forecaster(fg), id = "f1"),
    po("learner", recursive_forecaster(fg, lags = 1:2), id = "f2")
  )) %>>%
    po("fcst.regravg")

  p = as_learner(graph)$train(task)$predict(task, task$row_ids[c(22:24, 46:48)])
  expect_r6_class(p, "PredictionFcst")
  expect_equal(names(p$key), c("row_id", "key"))
  expect_equal(as.character(p$key$key), c("a", "a", "a", "b", "b", "b"))
})

test_that("PipeOpFcstAvg averages quantile forecasts per level", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  qs = c(0.1, 0.5, 0.9)
  mk = function(id) {
    po(
      "learner",
      lrn(paste0("fcst.", id), predict_type = "quantiles", quantiles = qs, quantile_response = 0.5),
      id = id
    )
  }
  graph = gunion(list(mk("auto_arima"), mk("ets"))) %>>% po("fcst.regravg")
  p = as_learner(graph)$train(task, 1:132)$predict(task, 133:144)

  expect_r6_class(p, "PredictionFcst")
  expect_subset("quantiles", p$predict_types)
  expect_equal(colnames(p$data$quantiles), c("q0.1", "q0.5", "q0.9"))

  # equals the per-level average of the two members
  l1 = lrn("fcst.auto_arima", predict_type = "quantiles", quantiles = qs, quantile_response = 0.5)$train(task, 1:132)
  l2 = lrn("fcst.ets", predict_type = "quantiles", quantiles = qs, quantile_response = 0.5)$train(task, 1:132)
  manual = (l1$predict(task, 133:144)$data$quantiles + l2$predict(task, 133:144)$data$quantiles) / 2
  expect_equal(unclass(p$data$quantiles), unclass(manual), ignore_attr = TRUE)
})

test_that("PipeOpFcstAvg errors when only some members predict quantiles", {
  skip_if_not_installed("forecast")
  task = tsk("airpassengers")
  graph = gunion(list(
    po(
      "learner",
      lrn("fcst.auto_arima", predict_type = "quantiles", quantiles = c(0.1, 0.5, 0.9), quantile_response = 0.5),
      id = "a"
    ),
    po("learner", lrn("fcst.ets"), id = "e")
  )) %>>%
    po("fcst.regravg")
  expect_snapshot(as_learner(graph)$train(task, 1:132)$predict(task, 133:144), error = TRUE)
})
