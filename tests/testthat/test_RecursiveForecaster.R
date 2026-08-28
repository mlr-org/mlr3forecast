test_that("RecursiveForecaster basic train/predict works", {
  task = tsk("airpassengers")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("RecursiveForecaster iterative prediction updates lags", {
  task = tsk("airpassengers")
  learner = RecursiveForecaster$new(lrn("regr.rpart", minsplit = 2L, cp = 0), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  # predictions should not all be identical since lags update between steps
  expect_false(length(unique(prediction$response)) == 1L)
})

test_that("RecursiveForecaster handles a non-unit integer index without explicit freq", {
  dt = data.table(time = seq(0L, by = 2L, length.out = 60L), value = as.numeric(1:60))
  task = as_task_fcst(dt, target = "value", order = "time")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("RecursiveForecaster treats a numeric freq as the seasonal period, not the step", {
  dt = data.table(time = 1:60, value = sin(2 * pi * (1:60) / 12))
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)

  task = as_task_fcst(dt, target = "value", order = "time", freq = 12)
  learner$train(task, 1:48)
  prediction = learner$predict(task, 49:60)
  expect_class(prediction, "PredictionRegr")

  ref_learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  ref_task = as_task_fcst(dt, target = "value", order = "time")
  ref_learner$train(ref_task, 1:48)
  expect_equal(prediction$response, ref_learner$predict(ref_task, 49:60)$response)
})

test_that("RecursiveForecaster works with keyed task", {
  task = make_date_major_panel_task(30L)
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("RecursiveForecaster works with an integer-keyed task", {
  skip_if_not_installed("rpart")
  dates = seq(as.Date("2020-01-01"), by = "day", length.out = 30L)
  data = CJ(date = dates, store = c(1L, 2L))
  data[, y := fifelse(store == 1L, 0L, 100L) + rowid(store)]
  task = TaskFcst$new("panel", as_data_backend(data), target = "y", order = "date", key = "store", freq = "day")
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)

  learner$train(task)
  prediction = forecast(learner, task, h = 3L)

  expect_identical(prediction$col_roles, list(order = "date", key = "store"))
  expect_integer(prediction$key$key)
  expect_setequal(unique(prediction$key$key), c(1L, 2L))
  expect_named(as.data.table(prediction), c("store", "date", "row_ids", "truth", "response"))
})

test_that("RecursiveForecaster works with graph constructor", {
  task = tsk("airpassengers")
  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  learner = RecursiveForecaster$new(graph)

  split = partition(task, ratio = 0.8)
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
})

test_that("RecursiveForecaster warns without iterative PipeOps", {
  task = tsk("airpassengers")
  task$col_roles$feature = "month"
  graph = po("colapply", applicator = as.numeric) %>>% lrn("regr.rpart")
  expect_warning(RecursiveForecaster$new(graph), "recursive")
})

test_that("RecursiveForecaster does not truncate predictions fed back into integer targets", {
  withr::local_seed(1)
  y = as.integer(round(100 + 10 * sin(seq_len(60) / 3) + rnorm(60, sd = 2)))
  dates = seq(as.Date("2020-01-01"), by = "day", length.out = 60L)
  make_task = function(y) {
    TaskFcst$new("t", as_data_backend(data.table(y = y, date = dates)), target = "y", order = "date", freq = "day")
  }
  task_int = make_task(y)
  task_dbl = make_task(as.numeric(y))

  flrn_int = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)$train(task_int, 1:50)
  flrn_dbl = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)$train(task_dbl, 1:50)
  expect_no_warning(p_int <- flrn_int$predict(task_int, 51:60))
  p_dbl = flrn_dbl$predict(task_dbl, 51:60)
  expect_equal(p_int$response, p_dbl$response)
})

test_that("RecursiveForecaster handles predict rows overlapping training rows", {
  task = tsk("airpassengers")
  flrn = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)$train(task)
  prediction = flrn$predict(task, 140:144)
  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, 5L)
})

test_that("RecursiveForecaster errors when test rows do not continue the training grid", {
  task = tsk("airpassengers")
  flrn = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  flrn$train(task, 1:120)
  expect_snapshot(flrn$predict(task, 126:130), error = TRUE)
  expect_snapshot(flrn$predict(task, c(121L, 123L)), error = TRUE)
})

test_that("RecursiveForecaster errors on gapped keyed test rows", {
  task = make_date_major_panel_task(10L)
  flrn = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:2)
  flrn$train(task, 1:16)
  expect_snapshot(flrn$predict(task, 19:20), error = TRUE)
})

test_that("RecursiveForecaster errors on target trafo inside the graph", {
  inner = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  graph = ppl("targettrafo", graph = inner, trafo_pipeop = po("fcst.targetdiff", lag = 1L))
  expect_snapshot(RecursiveForecaster$new(graph), error = TRUE)
})

test_that("RecursiveForecaster works wrapped in a target trafo", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.85)
  flrn = as_learner(ppl(
    "targettrafo",
    graph = recursive_forecaster(lrn("regr.rpart"), lags = 1:12),
    trafo_pipeop = po("fcst.targetdiff", lag = 1L)
  ))
  flrn$train(task, split$train)
  prediction = flrn$predict(task, split$test)

  expect_class(prediction, "PredictionRegr")
  expect_length(prediction$response, length(split$test))
  # predictions are inverted back to the original scale, not the differenced scale
  expect_numeric(prediction$response, lower = 100, finite = TRUE, any.missing = FALSE)
})

test_that("recursive_forecaster helper works", {
  learner = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  expect_class(learner, "RecursiveForecaster")
  expect_class(learner, "Learner")
  expect_equal(learner$lags, 1:3)

  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  learner = recursive_forecaster(graph)
  expect_class(learner, "RecursiveForecaster")
  expect_equal(learner$lags, 1:3)
})

test_that("RecursiveForecaster lags active binding", {
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:5)
  expect_equal(learner$lags, 1:5)

  graph = po("colapply", applicator = as.numeric) %>>% lrn("regr.rpart")
  learner = expect_warning(RecursiveForecaster$new(graph), "recursive")
  expect_null(learner$lags)
})

test_that("RecursiveForecaster deep clone isolates the inner learner", {
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  clone = learner$clone(deep = TRUE)
  clone$param_set$set_values(regr.rpart.cp = 0.5)
  expect_null(learner$param_set$values$regr.rpart.cp)
  expect_equal(clone$param_set$values$regr.rpart.cp, 0.5)
})

test_that("RecursiveForecaster native_model returns the base learner model", {
  task = tsk("airpassengers")
  learner = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  expect_null(learner$native_model)
  learner$train(task)
  expect_class(learner$native_model, "rpart")
})

test_that("RecursiveForecaster model prints a compact summary", {
  task = tsk("airpassengers")
  learner = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)$train(task)
  out = capture.output(print(learner$model))
  expect_lte(length(out), 6L)
  expect_match(out, "recursive_forecaster_model", all = FALSE)
  expect_match(out, "Training rows: 144", all = FALSE, fixed = TRUE)
})

test_that("RecursiveForecaster attaches measure weights to the prediction", {
  dt = tsk("airpassengers")$data(cols = c("month", "passengers"))
  set(dt, j = "w", value = as.numeric(seq_row(dt)))
  task = as_task_fcst(dt, target = "passengers", order = "month", freq = "month")
  task$set_col_roles("w", roles = "weights_measure")
  split = partition(task, ratio = 0.8)

  learner = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)$train(task, split$train)
  prediction = learner$predict(task, split$test)
  expected = task$weights_measure[list(row_id = prediction$row_ids), on = "row_id", "weight"][[1L]]
  expect_equal(prediction$weights, expected)
})

test_that("non-iterative graphs still attach the time index to the prediction", {
  task = tsk("airpassengers")
  split = partition(task, ratio = 0.9)
  learner = suppressWarnings(recursive_forecaster(po("fcst.fourier", K = 2L) %>>% lrn("regr.rpart")))
  learner$train(task, split$train)
  prediction = learner$predict(task, split$test)

  expect_r6_class(prediction, "PredictionFcst")
  expect_equal(prediction$order$order, task$data(rows = split$test, cols = "month")[[1L]])
})

test_that("RecursiveForecaster keeps supported wrapped-learner properties", {
  learner = recursive_forecaster(make_property_stub_learner(), lags = 1:3)
  expect_disjunct(learner$properties, c("hotstart_backward", "hotstart_forward"))
  expect_subset(
    c("importance", "internal_tuning", "missings", "oob_error", "selected_features", "validation"),
    learner$properties
  )

  learner = recursive_forecaster(lrn("regr.rpart"), lags = 1:3)
  expect_disjunct(
    learner$properties,
    c("hotstart_backward", "hotstart_forward", "internal_tuning", "validation")
  )
  expect_error(set_validate(learner, validate = 0.2), "validation")
  expect_error(
    {
      learner$validate = 0.2
    },
    "validation"
  )
})

test_that("RecursiveForecaster supports validation", {
  task = tsk("airpassengers")
  learner = recursive_forecaster(make_property_stub_learner(), lags = 1:3)
  set_validate(learner, validate = 0.2)
  expect_identical(learner$validate, 0.2)
  expect_identical(get_private(learner)$.learner$validate, "predefined")

  learner$train(task)
  expect_named(learner$internal_valid_scores, "regr.stub.mse")
  expect_number(learner$internal_valid_scores$regr.stub.mse)

  # validation rows stay in the recursion tail, so predicting the future grid still works
  split = partition(task, ratio = 0.9)
  learner$train(task, split$train)
  expect_r6_class(learner$predict(task, split$test), "PredictionFcst")

  set_validate(learner, validate = NULL)
  expect_null(learner$validate)
  expect_null(get_private(learner)$.learner$validate)
  learner$train(task)
  expect_null(learner$internal_valid_scores)
})

test_that("RecursiveForecaster supports predefined validation tasks", {
  task = tsk("airpassengers")
  task$internal_valid_task = tail(task$row_ids, 12L)
  learner = recursive_forecaster(make_property_stub_learner(), lags = 1:3)
  set_validate(learner, validate = "predefined")
  learner$train(task)
  expect_named(learner$internal_valid_scores, "regr.stub.mse")
})

test_that("RecursiveForecaster delegates importance, selected_features, and oob_error", {
  task = tsk("airpassengers")
  learner = recursive_forecaster(make_property_stub_learner(), lags = 1:3)
  expect_error(learner$importance(), "No model stored")
  expect_error(learner$selected_features(), "No model stored")
  expect_error(learner$oob_error(), "No model stored")

  learner$train(task)
  expect_numeric(learner$importance(), names = "unique")
  expect_character(learner$selected_features(), any.missing = FALSE)
  expect_identical(learner$oob_error(), 42)

  base = learner$base_learner()
  expect_r6_class(base, "LearnerRegrPropertyStub")
  expect_false(is.null(base$model))
})

test_that("RecursiveForecaster can be tuned with a validating learner", {
  skip_if_not_installed("mlr3tuning")
  task = tsk("airpassengers")
  learner = recursive_forecaster(make_property_stub_learner(), lags = 1:3)
  learner$param_set$set_values(regr.stub.shift = to_tune(0, 1))

  at = mlr3tuning::auto_tuner(
    tuner = mlr3tuning::tnr("random_search"),
    learner = learner,
    resampling = rsmp("fcst.cv", folds = 2L, horizon = 3L),
    measure = msr("regr.rmse"),
    term_evals = 2L
  )
  expect_error(at$train(task), NA)
  expect_number(at$tuning_result$regr.stub.shift)
})

test_that("RecursiveForecaster supports internal tuning", {
  skip_if_not_installed("mlr3tuning")
  task = tsk("airpassengers")
  learner = recursive_forecaster(make_property_stub_learner(), lags = 1:3)
  set_validate(learner, validate = "test")
  learner$param_set$set_values(
    regr.stub.early_stopping = TRUE,
    regr.stub.iter = to_tune(upper = 16L, internal = TRUE)
  )

  at = mlr3tuning::auto_tuner(
    tuner = mlr3tuning::tnr("internal"),
    learner = learner,
    resampling = rsmp("fcst.holdout", ratio = 0.8),
    measure = msr("internal_valid_score", select = "regr.stub.mse", minimize = TRUE),
    term_evals = 1L
  )
  at$train(task)

  internal_tuned = at$tuning_result$internal_tuned_values[[1L]]
  expect_named(internal_tuned, "regr.stub.iter")
  expect_identical(internal_tuned$regr.stub.iter, 8L)
  # disable_in_tune switches early stopping off for the final refit
  expect_false(at$learner$param_set$values$regr.stub.early_stopping)
  expect_identical(at$learner$param_set$values$regr.stub.iter, 8L)
})

test_that("RecursiveForecaster hash covers graph structure", {
  graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
  learner = RecursiveForecaster$new(graph, id = "x")
  same = RecursiveForecaster$new(po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart"), id = "x")
  expect_identical(learner$hash, same$hash)
  expect_identical(learner$phash, same$phash)

  # nop contributes no parameter values, so only the graph structure differs
  other_graph = RecursiveForecaster$new(
    po("fcst.lags", lags = 1:3) %>>% po("nop") %>>% lrn("regr.rpart"),
    id = "x"
  )
  expect_false(learner$hash == other_graph$hash)
  expect_false(learner$phash == other_graph$phash)

  other_values = learner$clone(deep = TRUE)
  other_values$param_set$values$fcst.lags.lags = 1:6
  expect_false(learner$hash == other_values$hash)
  expect_identical(learner$phash, other_values$phash)
})
