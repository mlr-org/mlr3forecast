skip_if_not_installed("nnfor")

test_that("autotest", {
  learner = lrn("fcst.mlp")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})
