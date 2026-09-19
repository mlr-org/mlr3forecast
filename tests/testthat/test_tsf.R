test_that("fread_tsf works", {
  file = system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast")
  act = read_tsf(file)
  expect_data_table(act, min.rows = 1, min.cols = 1)
  class(act) = class(act)[-1L]
  expect_equal(act, suppressWarnings(read_tsf_ref(file)), ignore_attr = c("frequency", "horizon"))
})

test_that("read_tsf preserves high-frequency timestamps", {
  skip_if_not_installed("withr")

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

test_that("read_tsf rejects timestamps without a time component", {
  skip_if_not_installed("withr")

  file = withr::local_tempfile(fileext = ".tsf")
  writeLines(
    c(
      "@attribute series_name string",
      "@attribute start_timestamp date",
      "@frequency yearly",
      "@data",
      "T1:1975-01-01:10,20,30,40"
    ),
    file
  )
  expect_error(read_tsf(file), "Incorrect timestamp format")
})

test_that("read_tsf handles frequency without date attribute", {
  skip_if_not_installed("withr")

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
  skip_if_not_installed("withr")

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
  expect_data_table(download_monash_dataset("m3_yearly"), min.rows = 1, min.cols = 1)
  # no index col
  expect_data_table(download_monash_dataset("m3_other"), min.rows = 1, min.cols = 1)
  # large data w/ NAs
  expect_data_table(download_monash_dataset("temperature_rain_with_missing_values"), min.rows = 1, min.cols = 1)
})

test_that("Monash dataset catalog resolves pinned Zenodo records", {
  expect_data_table(monash_datasets, nrows = 59L, ncols = 4L)
  expect_identical(anyDuplicated(monash_datasets$dataset), 0L)
  expect_identical(anyDuplicated(monash_datasets$record_id), 0L)
  expect_identical(anyDuplicated(monash_datasets$dataset_name), 0L)

  info = resolve_monash_dataset("m3_yearly")
  expect_identical(info$record_id, 4656222L)
  expect_identical(info$dataset_name, "m3_yearly_dataset")
  expect_false(info$has_missing)

  info = resolve_monash_dataset("nn5_daily_with_missing_values")
  expect_identical(info$record_id, 4656110L)
  expect_identical(info$dataset_name, "nn5_daily_dataset_with_missing_values")
  expect_true(info$has_missing)

  info = resolve_monash_dataset("nn5_daily")
  expect_identical(info$record_id, 4656117L)
  expect_identical(info$dataset_name, "nn5_daily_dataset_without_missing_values")
  expect_false(info$has_missing)
})

test_that("download_monash_dataset resolves the catalog and fills the horizon", {
  path = system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast")
  local_mocked_bindings(
    download_zenodo_file = function(record_id, file) {
      expect_identical(record_id, monash_datasets[dataset == "sunspot", record_id])
      expect_identical(file, "sunspot_dataset_without_missing_values")
      dt = read_tsf(path)
      setattr(dt, "horizon", NULL)
    }
  )

  dt = download_monash_dataset("sunspot")
  expect_data_table(dt, min.rows = 1L)
  expect_identical(attr(dt, "horizon"), 30L)
  expect_error(download_monash_dataset("unknown"), "Must be element of set")

  local_mocked_bindings(download_zenodo_file = function(record_id, file) setattr(read_tsf(path), "horizon", NULL))
  expect_null(attr(download_monash_dataset("m3_yearly"), "horizon"))
})

test_that("download_zenodo_record is deprecated", {
  local_mocked_bindings(download_zenodo_file = function(record_id, file) {
    read_tsf(system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast"))
  })
  expect_warning(download_zenodo_record(4656222, "m3_yearly_dataset"), class = "Mlr3WarningDeprecated")
})

test_that("set_monash_horizon fills benchmark horizons by dataset ID", {
  expect_subset(names(monash_horizons), monash_datasets$dataset)
  horizon = function(dataset, dt = data.table(value = 1)) attr(set_monash_horizon(dt, dataset), "horizon")
  expect_identical(horizon("sunspot"), 30L)
  expect_identical(horizon("kdd_cup_2018_with_missing_values"), 168L)
  expect_null(horizon("m3_yearly"))
  expect_identical(horizon("sunspot", setattr(data.table(value = 1), "horizon", 6L)), 6L)
})
