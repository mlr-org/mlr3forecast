test_that("fread_tsf works", {
  file = test_path("fixtures", "m3_yearly_dataset.tsf")
  act = read_tsf(file)
  expect_data_table(act, min.rows = 1, min.cols = 1)
  class(act) = class(act)[-1L]
  expect_equal(act, suppressWarnings(read_tsf_ref(file)), ignore_attr = c("frequency", "horizon"))
})

test_that("read_tsf preserves high-frequency timestamps", {
  file = withr::local_tempfile(fileext = ".tsf")
  writeLines(
    c(
      "@attribute series_name string",
      "@attribute start_timestamp date",
      "@frequency hourly",
      "@data",
      "T1:2012-01-01 09-30-00:10,20,30,40"
    ),
    file
  )
  dt = read_tsf(file)
  expect_equal(
    dt$start_timestamp,
    as.POSIXct("2012-01-01 09:30:00", tz = "UTC") + 3600 * (0:3)
  )
})

test_that("read_tsf handles frequency without date attribute", {
  file = withr::local_tempfile(fileext = ".tsf")
  writeLines(
    c(
      "@attribute series_name string",
      "@frequency yearly",
      "@data",
      "T1:10,20,30,40"
    ),
    file
  )
  dt = read_tsf(file)
  expect_data_table(dt, nrows = 4, ncols = 2)
  expect_equal(attr(dt, "frequency"), "yearly")
})

test_that("read_tsf sets the horizon attribute", {
  file = withr::local_tempfile(fileext = ".tsf")
  writeLines(
    c(
      "@attribute series_name string",
      "@frequency yearly",
      "@horizon 6",
      "@data",
      "T1:10,20,30,40"
    ),
    file
  )
  dt = read_tsf(file)
  expect_identical(attr(dt, "horizon"), 6L)
})

test_that("read_tsf works", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # simple data
  expect_data_table(download_zenodo_record(4656222, "m3_yearly_dataset"), min.rows = 1, min.cols = 1)
  # no index col
  expect_data_table(download_zenodo_record(4656335, "m3_other_dataset"), min.rows = 1, min.cols = 1)
  # large data w/ NAs
  expect_data_table(
    download_zenodo_record(5129073, "temperature_rain_dataset_with_missing_values"),
    min.rows = 1,
    min.cols = 1
  )
})
