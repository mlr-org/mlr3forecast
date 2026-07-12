test_that("PipeOpFcstSplitKey splits a keyed task into per-series tasks", {
  task = make_date_major_panel_task()
  po_split = po("fcst.splitkey")
  out = po_split$train(list(task))[[1L]]
  expect_class(out, "Multiplicity")
  expect_names(names(out), identical.to = c("a", "b"))
  expect_equal(po_split$state$keys$.label, c("a", "b"))

  for (sub in out) {
    expect_r6_class(sub, "TaskFcst")
    expect_false("keys" %in% sub$properties)
    expect_equal(sub$col_roles$key, character())
    expect_false("id" %in% sub$feature_names)
    expect_equal(sub$col_roles$order, "date")
    expect_equal(sub$freq, "day")
    expect_subset(sub$row_ids, task$row_ids)
    # the date-major fixture stores rows interleaved, the sub-tasks must be chronological
    expect_false(is.unsorted(sub$data(cols = "date")[[1L]], strictly = TRUE))
  }
  expect_equal(out$a$data(cols = "y")[[1L]], 1:10)
  expect_equal(out$b$data(cols = "y")[[1L]], 101:110)

  # predict emits the same partition in training order
  out = po_split$predict(list(task))[[1L]]
  expect_names(names(out), identical.to = c("a", "b"))
  expect_equal(out$a$data(cols = "y")[[1L]], 1:10)
})

test_that("PipeOpFcstSplitKey supports multi-column keys", {
  data = CJ(date = seq(as.Date("2020-01-01"), by = "day", length.out = 5L), a = factor(c("x", "y")), b = factor(c("l", "r")))
  set(data, j = "y", value = as.numeric(seq_row(data)))
  task = as_task_fcst(data, target = "y", order = "date", key = c("a", "b"), freq = "day")

  out = po("fcst.splitkey")$train(list(task))[[1L]]
  expect_class(out, "Multiplicity")
  expect_setequal(names(out), c("x:l", "x:r", "y:l", "y:r"))
  sub = out$`x:l`
  expect_equal(sub$nrow, 5L)
  expect_false("keys" %in% sub$properties)
  expect_length(intersect(c("a", "b"), sub$feature_names), 0L)
})

test_that("PipeOpFcstSplitKey disambiguates multi-column key labels containing the separator", {
  task = make_colon_key_panel_task()
  po_split = po("fcst.splitkey")
  out = po_split$train(list(task))[[1L]]

  expect_length(out, 2L)
  expect_equal(names(out), c("x:y:z", "x:y:z.1"))
  expect_equal(out[[1L]]$data(cols = "y")[[1L]], seq_len(12L))
  expect_equal(out[[2L]]$data(cols = "y")[[1L]], 100 + seq_len(12L)^2)

  pred = po_split$predict(list(task))[[1L]]
  expect_equal(names(pred), names(out))
  expect_equal(pred[[1L]]$data(cols = "y")[[1L]], seq_len(12L))
})

test_that("PipeOpFcstSplitKey errors on tasks without keys", {
  expect_snapshot(po("fcst.splitkey")$train(list(tsk("airpassengers"))), error = TRUE)
})

test_that("PipeOpFcstSplitKey errors on unseen or missing keys at predict", {
  task = make_date_major_panel_task()
  rows_a = task$row_ids[task$data(cols = "id")[[1L]] == "a"]

  po_split = po("fcst.splitkey")
  po_split$train(list(task$clone()$filter(rows_a)))
  expect_snapshot(po_split$predict(list(task)), error = TRUE)

  po_split = po("fcst.splitkey")
  po_split$train(list(task))
  expect_snapshot(po_split$predict(list(task$clone()$filter(rows_a))), error = TRUE)
})

test_that("splitkey/unitekey graph fits one local model per series", {
  task = make_date_major_panel_task()
  fg = po("fcst.lags", lags = 1L) %>>% lrn("regr.featureless")
  graph = po("fcst.splitkey") %>>% po("learner", recursive_forecaster(fg)) %>>% po("fcst.unitekey")
  glrn = as_learner(graph)
  expect_equal(glrn$task_type, "fcst")

  glrn$train(task)
  p = forecast(glrn, task, 3L)
  expect_r6_class(p, "PredictionFcst")
  expect_equal(nrow(p$order), 6L)
  expect_equal(as.character(p$key$key), rep(c("a", "b"), each = 3L))
  # featureless predicts each series' own train mean, a global fit would pool them
  expect_equal(p$response, rep(c(6, 106), each = 3L))
})

test_that("splitkey/unitekey graph works with resample", {
  task = make_date_major_panel_task()
  fg = po("fcst.lags", lags = 1L) %>>% lrn("regr.featureless")
  glrn = as_learner(po("fcst.splitkey") %>>% po("learner", recursive_forecaster(fg)) %>>% po("fcst.unitekey"))

  rr = resample(task, glrn, rsmp("fcst.holdout", n = 3L))
  expect_number(rr$aggregate(msr("regr.rmse")), finite = TRUE)
  rr = resample(task, glrn, rsmp("fcst.cv", folds = 2L, horizon = 2L))
  expect_number(rr$aggregate(msr("regr.rmse")), finite = TRUE)
})

test_that("classical learners fit local models through splitkey", {
  skip_if_not_installed("forecast")
  # monthly panel, ets warns about the non-integer seasonal period of daily data
  data = CJ(month = seq(as.Date("2020-01-01"), by = "month", length.out = 24L), id = factor(c("a", "b")))
  set(data, j = "y", value = fifelse(data$id == "a", 0, 100) + as.numeric(rowid(data$id)))
  task = as_task_fcst(data, target = "y", order = "month", key = "id", freq = "month")
  graph = po("fcst.splitkey") %>>% lrn("fcst.ets") %>>% po("fcst.unitekey")
  glrn = as_learner(graph)$train(task)
  p = forecast(glrn, task, 3L)
  expect_r6_class(p, "PredictionFcst")

  # equals training one ets per single-series task
  subtasks = po("fcst.splitkey")$train(list(task))[[1L]]
  manual = map(subtasks, function(sub) forecast(lrn("fcst.ets")$train(sub), sub, 3L))
  expect_equal(p$response, c(manual$a$response, manual$b$response))
})
