if (requireNamespace("testthat", quietly = TRUE)) {
  library("testthat")
  library("mlr3forecast")

  test_check("mlr3forecast")
}
