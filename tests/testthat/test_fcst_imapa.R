skip_if_not_installed("tsintermittent")

intermittent_task = function(n = 120L) {
  set.seed(1L)
  data = data.table(
    demand = rpois(n, 0.4) * rpois(n, 5),
    date = seq(as.Date("2020-01-01"), by = "day", length.out = n)
  )
  as_task_fcst(data, target = "demand", order = "date", id = "intermittent")
}

test_that("autotest", {
  learner = lrn("fcst.imapa")
  expect_learner(learner)
  # nolint next: unreachable_code_linter.
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("paramtest", {
  learner = lrn("fcst.imapa")
  expect_true(
    run_paramtest(learner, tsintermittent::imapa, tag = "train", exclude = c("data", "h", "outplot", "model.fit"))
  )
})

test_that("forecasts match a direct imapa call", {
  task = intermittent_task()
  learner = lrn("fcst.imapa", comb = "median", maximumAL = 5L)
  learner$train(task, 1:100)
  newdata = generate_newdata(task$clone()$filter(1:100), n = 6L)
  response = learner$predict_newdata(newdata)$response
  expect_numeric(response, any.missing = FALSE, len = 6L)

  y = task$data(rows = 1:100, cols = "demand")[[1L]]
  expected = tsintermittent::imapa(y, h = 6L, comb = "median", maximumAL = 5L, outplot = 0L)$frc.out
  expect_equal(response, as.numeric(expected))
})

test_that("in-sample prediction returns fitted demand rates", {
  task = intermittent_task()
  learner = lrn("fcst.imapa")
  learner$train(task, 1:100)
  response = learner$predict(task, 50:100)$response
  expect_numeric(response, any.missing = FALSE, len = 51L)
  expect_equal(response, as.numeric(learner$native_model$frc.in[50:100]))
})

test_that("one-step-ahead prediction works", {
  task = intermittent_task()
  learner = lrn("fcst.imapa")
  learner$train(task, 1:100)
  newdata = generate_newdata(task$clone()$filter(1:100), n = 1L)
  response = learner$predict_newdata(newdata)$response
  expect_numeric(response, any.missing = FALSE, len = 1L)
  y = task$data(rows = 1:100, cols = "demand")[[1L]]
  expect_equal(response, as.numeric(tsintermittent::imapa(y, h = 2L, outplot = 0L)$frc.out[1L]))
})
