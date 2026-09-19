test_that("list_monash_datasets returns a copy of the catalog", {
  datasets = list_monash_datasets()
  expect_data_table(datasets, nrows = nrow(monash_datasets), ncols = 6L)
  expect_names(names(datasets), permutation.of = names(monash_datasets))
  expect_identical(names(datasets)[1:4], c("dataset", "title", "has_missing", "size"))
  datasets[, dataset := "x"]
  expect_false("x" %in% monash_datasets$dataset)
})

test_that("Monash dataset catalog resolves pinned Zenodo records", {
  expect_data_table(monash_datasets, ncols = 6L)
  expect_integer(monash_datasets$size, lower = 1L, any.missing = FALSE)
  expect_identical(anyDuplicated(monash_datasets$dataset), 0L)
  expect_identical(anyDuplicated(monash_datasets$title), 0L)
  expect_identical(anyDuplicated(monash_datasets$record_id), 0L)
  expect_identical(anyDuplicated(monash_datasets$file), 0L)

  info = resolve_monash_dataset("m3_yearly")
  expect_identical(info$record_id, 4656222L)
  expect_identical(info$file, "m3_yearly_dataset")
  expect_false(info$has_missing)

  info = resolve_monash_dataset("nn5_daily_with_missing_values")
  expect_identical(info$record_id, 4656110L)
  expect_identical(info$file, "nn5_daily_dataset_with_missing_values")
  expect_true(info$has_missing)

  info = resolve_monash_dataset("nn5_daily")
  expect_identical(info$record_id, 4656117L)
  expect_identical(info$file, "nn5_daily_dataset_without_missing_values")
  expect_false(info$has_missing)
})
