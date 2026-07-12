make_series_prediction = function(row_ids, response, start = as.Date("2020-01-01"), quantiles = NULL) {
  PredictionFcst$new(
    row_ids = row_ids,
    truth = rep(NA_real_, length(row_ids)),
    response = response,
    quantiles = quantiles,
    extra = list(date = seq(start, by = "day", length.out = length(row_ids)))
  )
}

trained_unitekey = function(labels = c("a", "b")) {
  po_unite = po("fcst.unitekey")
  po_unite$train(list(invoke(Multiplicity, .args = named_list(labels))))
  po_unite
}

test_that("PipeOpFcstUniteKey row-binds per-series predictions and rebuilds the key", {
  p1 = make_series_prediction(1:3, c(1, 2, 3))
  p2 = make_series_prediction(4:6, c(10, 20, 30))
  po_unite = trained_unitekey()

  out = po_unite$predict(list(Multiplicity(a = p1, b = p2)))[[1L]]
  expect_r6_class(out, "PredictionFcst")
  expect_equal(out$row_ids, 1:6)
  expect_equal(out$response, c(1, 2, 3, 10, 20, 30))
  expect_equal(out$key$key, factor(rep(c("a", "b"), each = 3L)))
  expect_equal(out$order$order, rep(seq(as.Date("2020-01-01"), by = "day", length.out = 3L), 2L))
})

test_that("PipeOpFcstUniteKey preserves quantile predictions", {
  q1 = make_quantiles(c(0, 1, 2), c(2, 3, 4))
  q2 = make_quantiles(c(9, 19, 29), c(11, 21, 31))
  p1 = make_series_prediction(1:3, c(1, 2, 3), quantiles = q1)
  p2 = make_series_prediction(4:6, c(10, 20, 30), quantiles = q2)
  po_unite = trained_unitekey()

  out = po_unite$predict(list(Multiplicity(a = p1, b = p2)))[[1L]]
  expect_subset("quantiles", out$predict_types)
  expect_equal(unclass(out$data$quantiles), rbind(unclass(q1), unclass(q2)), ignore_attr = TRUE)
  expect_equal(attr(out$data$quantiles, "probs"), attr(q1, "probs"))
  expect_equal(out$key$key, factor(rep(c("a", "b"), each = 3L)))
})

test_that("PipeOpFcstUniteKey rejects per-series predictions with different quantile levels", {
  q1 = make_quantiles(c(0, 1, 2), c(2, 3, 4), probs = c(0.1, 0.9))
  q2 = make_quantiles(c(9, 19, 29), c(11, 21, 31), probs = c(0.25, 0.75))
  p1 = make_series_prediction(1:3, c(1, 2, 3), quantiles = q1)
  p2 = make_series_prediction(4:6, c(10, 20, 30), quantiles = q2)
  po_unite = trained_unitekey()

  expect_error(po_unite$predict(list(Multiplicity(a = p1, b = p2))), "different quantile levels")
})

test_that("PipeOpFcstUniteKey attaches the key for a single series", {
  p1 = make_series_prediction(1:3, c(1, 2, 3))
  po_unite = trained_unitekey("a")

  out = po_unite$predict(list(Multiplicity(a = p1)))[[1L]]
  expect_equal(out$response, c(1, 2, 3))
  expect_equal(out$key$key, factor(c("a", "a", "a")))
})

test_that("PipeOpFcstUniteKey errors on unnamed multiplicities", {
  p1 = make_series_prediction(1:3, c(1, 2, 3))
  p2 = make_series_prediction(4:6, c(10, 20, 30))
  po_unite = po("fcst.unitekey")
  po_unite$train(list(Multiplicity(NULL, NULL)))
  expect_snapshot(po_unite$predict(list(Multiplicity(p1, p2))), error = TRUE)
})

test_that("PipeOpFcstUniteKey names the rebuilt key column via the key parameter", {
  p1 = make_series_prediction(1:3, c(1, 2, 3))
  p2 = make_series_prediction(4:6, c(10, 20, 30))
  po_unite = po("fcst.unitekey", key = "id")
  po_unite$train(list(Multiplicity(a = NULL, b = NULL)))

  out = po_unite$predict(list(Multiplicity(a = p1, b = p2)))[[1L]]
  expect_equal(names(out$data$extra), c("date", "id"))
  expect_equal(out$key$key, factor(rep(c("a", "b"), each = 3L)))
  expect_named(as.data.table(out), c("id", "date", "row_ids", "truth", "response"))
})

test_that("PipeOpFcstUniteKey rejects a key name colliding with an existing extra column", {
  p1 = make_series_prediction(1:3, c(1, 2, 3))
  p2 = make_series_prediction(4:6, c(10, 20, 30))
  po_unite = po("fcst.unitekey", key = "date")
  po_unite$train(list(Multiplicity(a = NULL, b = NULL)))

  expect_error(po_unite$predict(list(Multiplicity(a = p1, b = p2))), "already carries an extra column")
})
