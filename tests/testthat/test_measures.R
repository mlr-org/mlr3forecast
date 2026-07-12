test_that("forecast measures", {
  keys = mlr_measures$keys("^fcst\\.")
  task = tsk("california_housing")
  learner = lrn("regr.rpart")
  train_set = seq_len(task$nrow)
  p = learner$train(task)$predict(task)

  for (key in keys) {
    m = mlr_measures$get(key)
    if ((is.na(m$task_type) || m$task_type == "regr") && m$predict_type == "response") {
      perf = m$score(prediction = p, task = task, learner = learner, train_set = train_set)
      expect_number(perf, na.ok = FALSE, lower = m$range[1L], upper = m$range[2L])
    }
  }
})

test_that("MeasureMDA works", {
  measure = msr("fcst.mda")
  task = tsk("airpassengers")
  truth = c(0, 5)
  response = c(1, 6)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mda = 1.0))
  response = c(2, -2)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mda = 0.0))
  # returns 1 when all directions are correct
  truth = 0:10
  response = truth + 2
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mda = 1.0))
  # returns 0.5 when half the directions are correct
  truth = 1:5
  response = frev(truth)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mda = 0.5))
  # returns 0 when all directions are wrong
  truth = 1:5
  response = truth - 1L
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mda = 0.0))
  # returns 1 for constant series
  truth = response = rep.int(7, 5)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mda = 1.0))
})

test_that("MeasureMDV works", {
  measure = msr("fcst.mdv")
  task = tsk("airpassengers")
  # returns +1 when all directions are correct
  truth = 0:10
  response = truth + 2
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mdv = 1.0))
  # returns –1 when all directions are wrong
  truth = 0:10
  response = truth - 1L
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mdv = -1.0))
  # returns 0 for constant series
  truth = response = rep.int(7, 5)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mdv = 0.0))
})

test_that("MeasureMDPV works", {
  measure = msr("fcst.mdpv")
  task = tsk("airpassengers")
  # returns +100 when all directions are correct
  truth = c(1, 2, 4, 8, 16)
  response = truth + 1L
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mdpv = 1.0))
  # returns –100 when all directions are wrong
  response = rep.int(0, length(truth))
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mdpv = -1.0))
  # returns 0 for constant series
  truth = response = rep.int(7, 5)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_identical(pred$score(measure, task = task), c(fcst.mdpv = 0.0))
})

test_that("MeasureMPE works", {
  measure = msr("fcst.mpe")
  # perfect forecast
  truth = c(10, 20, 30)
  pred = PredictionRegr$new(truth = truth, response = truth, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.mpe = 0.0))
  # under-forecasting gives positive MPE
  response = c(8, 16, 24)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_true(unname(pred$score(measure)) > 0)
  # over-forecasting gives negative MPE
  response = c(12, 24, 36)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_true(unname(pred$score(measure)) < 0)
})

test_that("MeasureWAPE works", {
  measure = msr("fcst.wape")
  # perfect forecast
  truth = c(10, 20, 30)
  pred = PredictionRegr$new(truth = truth, response = truth, row_ids = seq_along(truth))
  expect_identical(pred$score(measure), c(fcst.wape = 0.0))
  # known value: 100 * sum|e| / sum|y|
  response = c(8, 24, 27)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_equal(unname(pred$score(measure)), 100 * sum(abs(truth - response)) / sum(abs(truth)))
  # large errors relative to small series can exceed 100
  pred = PredictionRegr$new(truth = c(1, 1), response = c(5, 5), row_ids = 1:2)
  expect_equal(unname(pred$score(measure)), 400)
})

test_that("MeasureACF1 works", {
  measure = msr("fcst.acf1")
  task = tsk("airpassengers")
  # non-trivial residuals produce a value in [-1, 1]
  truth = c(10, 12, 11, 15, 13, 18, 16)
  response = c(10.5, 11.5, 12, 14, 14, 17, 15)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = seq_along(truth))
  expect_number(unname(pred$score(measure, task = task)), lower = -1, upper = 1)
  # single observation returns NA
  pred = PredictionRegr$new(truth = 1, response = 1, row_ids = 1L)
  expect_identical(unname(pred$score(measure, task = task)), NA_real_)
})

test_that("MeasureCoverage works", {
  measure = msr("fcst.coverage")
  truth = c(10, 20, 30, 40, 50)
  # all inside
  quantiles = make_quantiles(c(5, 15, 25, 35, 45), c(15, 25, 35, 45, 55))
  pred = PredictionRegr$new(
    truth = truth,
    response = rep(0, 5),
    quantiles = quantiles,
    row_ids = seq_along(truth)
  )
  expect_equal(unname(pred$score(measure)), 1)
  # all outside
  quantiles = make_quantiles(c(11, 21, 31, 41, 51), c(12, 22, 32, 42, 52))
  pred = PredictionRegr$new(
    truth = truth,
    response = rep(0, 5),
    quantiles = quantiles,
    row_ids = seq_along(truth)
  )
  expect_equal(unname(pred$score(measure)), 0)
  # 3 out of 5 inside
  quantiles = make_quantiles(c(5, 15, 31, 35, 51), c(15, 25, 32, 45, 52))
  pred = PredictionRegr$new(
    truth = truth,
    response = rep(0, 5),
    quantiles = quantiles,
    row_ids = seq_along(truth)
  )
  expect_equal(unname(pred$score(measure)), 0.6)
  # on boundary counts as inside
  quantiles = make_quantiles(10, 10)
  pred = PredictionRegr$new(truth = 10, response = 0, quantiles = quantiles, row_ids = 1L)
  expect_equal(unname(pred$score(measure)), 1)
})

test_that("MeasureWinkler works", {
  measure = msr("fcst.winkler")
  truth = c(10, 20, 30, 40, 50)
  # all observations inside the interval: score = width
  quantiles = make_quantiles(c(5, 15, 25, 35, 45), c(15, 25, 35, 45, 55))
  pred = PredictionRegr$new(
    truth = truth,
    response = rep(0, 5),
    quantiles = quantiles,
    row_ids = seq_along(truth)
  )
  expect_equal(unname(pred$score(measure)), 10)
  # observation below interval: width + penalty
  quantiles = make_quantiles(5, 15)
  pred = PredictionRegr$new(truth = 0, response = 0, quantiles = quantiles, row_ids = 1L)
  # width = 10, penalty = (2/0.05) * (5 - 0) = 200
  expect_equal(unname(pred$score(measure)), 210)
  # observation above interval: width + penalty
  pred = PredictionRegr$new(truth = 20, response = 0, quantiles = quantiles, row_ids = 1L)
  # width = 10, penalty = (2/0.05) * (20 - 15) = 200
  expect_equal(unname(pred$score(measure)), 210)
  # missing truth is dropped, not scored as interval width
  quantiles = make_quantiles(c(5, 5), c(15, 15))
  pred = PredictionRegr$new(truth = c(NA, 20), response = c(0, 0), quantiles = quantiles, row_ids = 1:2)
  expect_equal(unname(pred$score(measure)), 210)
})

test_that("MeasurePinball works", {
  measure = msr("fcst.pinball")
  truth = c(10, 20, 30, 40, 50)
  # perfect forecast at every quantile gives 0
  quantiles = make_quantiles(truth, truth)
  pred = PredictionRegr$new(
    truth = truth,
    response = rep(0, 5),
    quantiles = quantiles,
    row_ids = seq_along(truth)
  )
  expect_identical(unname(pred$score(measure)), 0.0)
  # lower bound below truth -> tau * (y - q); upper bound above truth -> (1 - tau) * (q - y)
  # with probs c(0.025, 0.975) and a distance of 2 on each side, every loss term is 0.025 * 2 = 0.05,
  # and the score is twice the mean loss
  quantiles = make_quantiles(truth - 2, truth + 2)
  pred = PredictionRegr$new(
    truth = truth,
    response = rep(0, 5),
    quantiles = quantiles,
    row_ids = seq_along(truth)
  )
  expect_equal(unname(pred$score(measure)), 0.1)
})

test_that("MeasureMASE works", {
  measure = msr("fcst.mase")
  task = tsk("airpassengers")
  train_ids = 1:120
  test_ids = 121:144
  truth = task$data(rows = test_ids, cols = task$target_names)[[1L]]
  response = truth + 10
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = test_ids)
  result = unname(pred$score(measure, task = task, train_set = train_ids))
  expect_number(result, lower = 0)
  # perfect forecast gives 0
  pred = PredictionRegr$new(truth = truth, response = truth, row_ids = test_ids)
  expect_equal(unname(pred$score(measure, task = task, train_set = train_ids)), 0)
})

test_that("keyed scoring handles partially observed key groups", {
  task = tsk("livestock")
  key = task$data(cols = task$col_roles$key)[[1L]]
  ids = task$row_ids[key == levels(key)[1L]]
  n = length(ids)
  train_ids = ids[1:(n - 5L)]
  test_ids = ids[(n - 4L):n]
  truth = task$data(rows = test_ids, cols = task$target_names)[[1L]]
  pred = PredictionRegr$new(truth = truth, response = truth + 1, row_ids = test_ids)
  expect_number(unname(pred$score(msr("fcst.mase"), task = task, train_set = train_ids)), finite = TRUE)
})

test_that("keyed scoring errors for key groups absent from the training set", {
  task = tsk("livestock")
  key = task$data(cols = task$col_roles$key)[[1L]]
  train_ids = task$row_ids[key == levels(key)[1L]]
  test_ids = head(task$row_ids[key == levels(key)[2L]], 5L)
  truth = task$data(rows = test_ids, cols = task$target_names)[[1L]]
  pred = PredictionRegr$new(truth = truth, response = truth, row_ids = test_ids)
  expect_snapshot(pred$score(msr("fcst.mase"), task = task, train_set = train_ids), error = TRUE)
})

test_that("MeasureRMSSE works", {
  measure = msr("fcst.rmsse")
  task = tsk("airpassengers")
  train_ids = 1:120
  test_ids = 121:144
  truth = task$data(rows = test_ids, cols = task$target_names)[[1L]]
  response = truth + 10
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = test_ids)
  result = unname(pred$score(measure, task = task, train_set = train_ids))
  expect_number(result, lower = 0)
  # perfect forecast gives 0
  pred = PredictionRegr$new(truth = truth, response = truth, row_ids = test_ids)
  expect_equal(unname(pred$score(measure, task = task, train_set = train_ids)), 0)
})

test_that("measures match fabletools reference implementation", {
  skip_if_not_installed("fabletools")
  skip_if_not_installed("distributional")
  skip_if_not_installed("vctrs")

  task = tsk("airpassengers")
  truth = c(10, 12, 11, 15, 13, 18, 16)
  response = c(10.5, 11.5, 12, 14, 14, 17, 15)
  resid = truth - response
  row_ids = seq_along(truth)
  pred = PredictionRegr$new(truth = truth, response = response, row_ids = row_ids)

  # MDA
  expected_mda = fabletools::MDA(resid, truth)
  expect_equal(unname(pred$score(msr("fcst.mda"), task = task)), expected_mda)

  # MDA with custom reward/penalty
  expected_mda_custom = fabletools::MDA(resid, truth, reward = 1, penalty = -1)
  expect_equal(
    unname(pred$score(msr("fcst.mda", reward = 1, penalty = -1), task = task)),
    expected_mda_custom
  )

  # MDV
  expected_mdv = fabletools::MDV(resid, truth)
  expect_equal(unname(pred$score(msr("fcst.mdv"), task = task)), expected_mdv)

  # MPE
  expected_mpe = fabletools::MPE(resid, truth)
  expect_equal(unname(pred$score(msr("fcst.mpe"))), expected_mpe)

  # ACF1
  expected_acf1 = fabletools::ACF1(resid)
  expect_equal(unname(pred$score(msr("fcst.acf1"), task = task)), expected_acf1)

  # Winkler
  d = distributional::dist_normal(truth, 2)
  h = distributional::hilo(d, 95)
  lower = vctrs::field(h, "lower")
  upper = vctrs::field(h, "upper")
  quantiles = make_quantiles(lower, upper)
  pred_q = PredictionRegr$new(
    truth = truth,
    response = response,
    quantiles = quantiles,
    row_ids = row_ids
  )
  expected_winkler = fabletools::winkler_score(d, truth, level = 95)
  expect_equal(unname(pred_q$score(msr("fcst.winkler"))), expected_winkler)

  # Pinball
  probs = c(0.1, 0.5, 0.9)
  qmat = vapply(probs, function(p) unname(quantile(d, p)), numeric(length(truth)))
  colnames(qmat) = sprintf("q%s", probs)
  setattr(qmat, "probs", probs)
  setattr(qmat, "response", 0.5)
  pred_pinball = PredictionRegr$new(
    truth = truth,
    response = response,
    quantiles = qmat,
    row_ids = row_ids
  )
  expected_pinball = fabletools::quantile_score(d, truth, probs = probs)
  expect_equal(unname(pred_pinball$score(msr("fcst.pinball"))), expected_pinball)

  # MASE
  train_ids = 1:120
  test_ids = 121:144
  train_data = task$data(rows = train_ids, cols = task$target_names)[[1L]]
  test_truth = task$data(rows = test_ids, cols = task$target_names)[[1L]]
  test_response = test_truth + rnorm(length(test_ids))
  test_resid = test_truth - test_response
  pred_ts = PredictionRegr$new(truth = test_truth, response = test_response, row_ids = test_ids)
  expected_mase = fabletools::MASE(test_resid, train_data, .period = 1)
  expect_equal(
    unname(pred_ts$score(msr("fcst.mase"), task = task, train_set = train_ids)),
    expected_mase
  )
  # seasonal MASE with period = 12
  expected_mase_12 = fabletools::MASE(test_resid, train_data, .period = 12)
  expect_equal(
    unname(pred_ts$score(msr("fcst.mase", period = 12L), task = task, train_set = train_ids)),
    expected_mase_12
  )

  # RMSSE
  expected_rmsse = fabletools::RMSSE(test_resid, train_data, .period = 1)
  expect_equal(
    unname(pred_ts$score(msr("fcst.rmsse"), task = task, train_set = train_ids)),
    expected_rmsse
  )
  # seasonal RMSSE with period = 12
  expected_rmsse_12 = fabletools::RMSSE(test_resid, train_data, .period = 12)
  expect_equal(
    unname(pred_ts$score(msr("fcst.rmsse", period = 12L), task = task, train_set = train_ids)),
    expected_rmsse_12
  )
})

test_that("fcst.msis matches greybox::sMIS reference", {
  skip_if_not_installed("greybox")
  withr::local_seed(1)

  task = tsk("airpassengers")
  train_ids = 1:120
  test_ids = 121:144
  train = task$data(rows = train_ids, cols = task$target_names)[[1L]]
  truth = task$data(rows = test_ids, cols = task$target_names)[[1L]]
  response = truth + rnorm(length(test_ids), 0, 10)
  lower = response - 25
  upper = response + 30
  qmat = cbind(lower, upper)
  setattr(qmat, "probs", c(0.025, 0.975))
  pred = PredictionRegr$new(truth = truth, response = response, quantiles = qmat, row_ids = test_ids)

  for (m in c(1L, 12L)) {
    scale = mean(abs(diff(train, lag = m)))
    expect_equal(
      unname(pred$score(msr("fcst.msis", period = m), task = task, train_set = train_ids)),
      greybox::sMIS(truth, lower, upper, scale = scale, level = 0.95)
    )
  }
})

test_that("fcst.msis on a keyed task averages per-series scaled scores", {
  skip_if_not_installed("greybox")
  withr::local_seed(2)

  dt = rbindlist(map(c("A", "B"), function(k) {
    data.table(
      id = factor(k, levels = c("A", "B")),
      date = seq(as.Date("2010-01-01"), by = "month", length.out = 60L),
      y = as.numeric(cumsum(rnorm(60L, 2, 5)) + 100 + 50 * (k == "B"))
    )
  }))
  task = as_task_fcst(dt, target = "y", order = "date", key = "id", freq = "month")
  d = task$data(cols = c("id", "date"))
  set(d, j = "rid", value = task$row_ids)
  setorder(d, id, date)
  train_ids = d[, head(rid, 48L), by = id]$V1
  test_ids = d[, tail(rid, 12L), by = id]$V1

  truth = task$data(rows = test_ids, cols = "y")[[1L]]
  response = truth + rnorm(length(test_ids), 0, 8)
  lower = response - 20
  upper = response + 22
  qmat = cbind(lower, upper)
  setattr(qmat, "probs", c(0.025, 0.975))
  pred = PredictionRegr$new(truth = truth, response = response, quantiles = qmat, row_ids = test_ids)

  test_key = task$data(rows = test_ids, cols = "id")[[1L]]
  train_key = task$data(rows = train_ids, cols = "id")[[1L]]
  train_y = task$data(rows = train_ids, cols = "y")[[1L]]
  per_key = map_dbl(
    c("A", "B"),
    function(k) {
      sel = test_key == k
      scale = mean(abs(diff(train_y[train_key == k], lag = 12L)))
      greybox::sMIS(truth[sel], lower[sel], upper[sel], scale = scale, level = 0.95)
    }
  )

  expect_equal(
    unname(pred$score(msr("fcst.msis", period = 12L), task = task, train_set = train_ids)),
    mean(per_key)
  )
})
