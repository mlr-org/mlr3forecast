Sys.setenv(OMP_NUM_THREADS = "1")

if (requireNamespace("testthat", quietly = TRUE)) {
  library("testthat")
  library("mlr3forecast")

  test_check("mlr3forecast")
}
