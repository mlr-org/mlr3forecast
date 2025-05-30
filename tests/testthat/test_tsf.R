test_that("fread_tsf works", {
  file = test_path("fixtures", "m3_yearly_dataset.tsf")
  act = read_tsf(file)
  expect_data_table(act)
  class(act) = class(act)[-1L]
  expect_equal(act, suppressWarnings(read_tsf_ref(file)), ignore_attr = "frequency")
})

test_that("read_tsf works", {
  skip_on_cran()
  skip_on_ci()

  expect_data_table(download_zenodo_record(4656222, "m3_yearly_dataset"))
  # no index col
  expect_data_table(download_zenodo_record(4656335, "m3_other_dataset"))
})
