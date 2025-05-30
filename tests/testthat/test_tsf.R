test_that("fread_tsf works", {
  file = test_path("fixtures", "m3_yearly_dataset.tsf")
  act = read_tsf(file)
  expect_data_table(act)
  class(act) = class(act)[-1L]
  expect_equal(act, suppressWarnings(read_tsf_ref(file)), ignore_attr = "frequency")
})
