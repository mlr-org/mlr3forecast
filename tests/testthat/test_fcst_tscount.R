skip_if_not_installed("tscount")

test_that("autotest", {
  learner = lrn("fcst.tscount")
  expect_learner(learner)
  if (FALSE) {
    result = run_autotest(learner)
    expect_true(result, info = result$error)
  }
})

test_that("training reads the count series chronologically", {
  withr::local_seed(2)
  n = 48L
  dat = data.table(t = 1:n, y = as.integer(rpois(n, lambda = pmax(1, round(5 + 4 * sin((1:n) / 2))))))
  sorted = as_task_fcst(dat, target = "y", order = "t")
  shuffled = as_task_fcst(dat[sample(n)], target = "y", order = "t")

  # tsglm treats the series as ordered, so a misread backend fits a different model
  m_sorted = lrn("fcst.tscount", past_obs = 1L)$train(sorted)$native_model
  m_shuffled = lrn("fcst.tscount", past_obs = 1L)$train(shuffled)$native_model
  expect_equal(coef(m_shuffled), coef(m_sorted))
})
