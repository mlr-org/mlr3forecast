skip_if_not_installed("tsintermittent")

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
    run_paramtest(
      learner,
      tsintermittent::imapa,
      tag = "train",
      exclude = c("data", "h", "outplot", "model.fit", "probs", "qtype")
    )
  )
})

test_that("forecasts match a direct imapa call", {
  set.seed(1L)
  y = rpois(100L, 0.4) * rpois(100L, 5)
  data = data.table(demand = y, date = seq(as.Date("2020-01-01"), by = "day", length.out = 100L))
  task = as_task_fcst(data, target = "demand", order = "date")
  learner = lrn("fcst.imapa", comb = "median", maximumAL = 5L)$train(task)
  response = learner$predict_newdata(generate_newdata(task, n = 6L))$response
  expected = tsintermittent::imapa(y, h = 6L, comb = "median", maximumAL = 5L, outplot = 0L)$frc.out
  expect_identical(response, as.numeric(expected))
})
