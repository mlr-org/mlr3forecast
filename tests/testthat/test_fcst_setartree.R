skip_if_not_installed("setartree")

test_that("autotest", {
  learner = lrn("fcst.setartree")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.setartree")
  expect_true(
    run_paramtest(learner, setartree::setartree, tag = "train", exclude = c("data", "label", "categorical_covariates"))
  )
})

test_that("response and quantile prediction work", {
  task = tsk("airpassengers")
  learner = lrn("fcst.setartree", lag = 12L)
  learner$train(task, 1:132)
  expect_class(learner$native_model, "setartree")

  response = learner$predict(task, 133:144)$response
  expect_numeric(response, finite = TRUE, any.missing = FALSE, len = 12L)

  learner$predict_type = "quantiles"
  learner$quantiles = c(0.1, 0.5, 0.9)
  learner$quantile_response = 0.5
  quantiles = learner$predict(task, 133:144)$quantiles
  expect_matrix(quantiles, nrows = 12L, ncols = 3L)
  expect_equal(quantiles[, 2L], response)
  expect_all_true(quantiles[, 1L] < quantiles[, 2L])
  expect_all_true(quantiles[, 2L] < quantiles[, 3L])
})

test_that("in-sample prediction is not supported", {
  task = tsk("airpassengers")
  learner = lrn("fcst.setartree")
  learner$train(task, 1:132)
  expect_error(learner$predict(task, 1:12), "not supported")
})

test_that("keyed tasks fit one global model across series", {
  task = tgen("arima", k = 3L)$generate(40L)
  learner = lrn("fcst.setartree", lag = 4L)
  learner$train(task)
  expect_class(learner$native_model, "setartree")

  newdata = generate_newdata(task, n = 3L)
  pred = learner$predict_newdata(newdata, task)
  expect_identical(pred$data$col_roles$key, "series")

  dt = task$data(cols = c("series", "time", "y"), ordered = TRUE)
  y = split(dt$y, dt$series)
  expected = map(generics::forecast(learner$native_model, newdata = unname(y), h = 3L)$forecast, "mean")
  expect_equal(pred$response, as.numeric(unlist(expected)))

  # rows of a subset of keys in arbitrary order map back to their own series and step
  shuffled = newdata[c(9L, 4L, 7L, 5L, 8L, 6L)]
  pred = learner$predict_newdata(shuffled, task)
  expect_equal(pred$response, as.numeric(unlist(expected))[c(9L, 4L, 7L, 5L, 8L, 6L)])
})

test_that("keyed prediction rejects unseen keys, gaps, and in-sample rows", {
  task = tgen("arima", k = 3L)$generate(40L)
  learner = lrn("fcst.setartree", lag = 4L)
  learner$train(task, task$row_ids[task$data(cols = "series")$series != "3"])

  newdata = generate_newdata(task, n = 2L)
  expect_error(learner$predict_newdata(newdata, task), "not seen during training")
  newdata = newdata[series != "3"]
  expect_error(learner$predict_newdata(newdata[-1L], task), "gap-free future grid.*'1'")
  expect_error(learner$predict(task, 1:3), "not supported")
})

test_that("each series needs more than lag observations", {
  task = tgen("arima", k = 2L)$generate(8L)
  expect_error(lrn("fcst.setartree", lag = 8L)$train(task), "too short")
  expect_error(lrn("fcst.setartree", lag = 8L)$train(tsk("airpassengers"), 1:8), "more than `lag = 8`")
})

test_that("resampling works on keyed tasks", {
  task = tgen("arima", k = 3L)$generate(40L)
  rr = resample(task, lrn("fcst.setartree", lag = 4L), rsmp("fcst.holdout", ratio = 0.8))
  expect_number(rr$aggregate(msr("regr.mae")), finite = TRUE)
})
