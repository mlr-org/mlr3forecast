test_that("ppl(\"fcst.local\") wraps a graph between splitkey and unitekey", {
  task = make_date_major_panel_task()
  fg = po("fcst.lags", lags = 1L) %>>% lrn("regr.featureless")
  graph = ppl("fcst.local", recursive_forecaster(fg))
  expect_class(graph, "Graph")
  expect_subset(c("fcst.splitkey", "fcst.unitekey"), graph$ids())

  glrn = as_learner(graph)
  expect_equal(glrn$task_type, "fcst")
  p = forecast(glrn$train(task), task, 3L)
  expect_r6_class(p, "PredictionFcst")
  expect_equal(p$response, rep(c(6, 106), each = 3L))
  expect_equal(as.character(p$key$key), rep(c("a", "b"), each = 3L))
})

test_that("ppl(\"fcst.local\") composes with classical learners", {
  skip_if_not_installed("forecast")
  data = CJ(month = seq(as.Date("2020-01-01"), by = "month", length.out = 24L), id = factor(c("a", "b")))
  set(data, j = "y", value = fifelse(data$id == "a", 0, 100) + as.numeric(rowid(data$id)))
  task = as_task_fcst(data, target = "y", order = "month", key = "id", freq = "month")

  glrn = as_learner(ppl("fcst.local", lrn("fcst.ets")))$train(task)
  manual = as_learner(po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey"))$train(task)
  expect_equal(forecast(glrn, task, 3L)$response, forecast(manual, task, 3L)$response)
})
