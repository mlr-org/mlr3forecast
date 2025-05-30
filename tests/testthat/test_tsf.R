test_that("fread_tsf works", {
  file = test_path("fixtures", "m3_yearly_dataset.tsf")
  act = read_tsf(file)
  expect_data_table(act)
  expect_identical(act, suppressWarnings(read_tsf_ref(file)))
})
