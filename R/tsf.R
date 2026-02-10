#' @title Read tsf files
#'
#' @description
#' Parses a file located at `file` and returns a [data.table::data.table()].
#'
#' @param file (`character(1)`)\cr
#'   The path to the TSF file.
#' @return ([data.table::data.table()]).
#'
#' @references
#' `r format_bib("godahewa2021monash")`
#'
#' @export
read_tsf = function(file) {
  assert_file(file, extension = "tsf")

  low_frequencies = c("daily", "weekly", "monthly", "quarterly", "yearly")
  high_frequencies = c("4_seconds", "minutely", "10_minutes", "15_minutes", "half_hourly", "hourly")

  con = file(file, "r")
  on.exit(close(con), add = TRUE)
  skip = 1L
  metadata = character()
  freq = character()
  horizon = integer() # nolint

  repeat {
    line = readLines(con, n = 1L, warn = FALSE)
    if (length(line) == 0L) {
      stopf("No @data section found")
    }
    if (startsWith(line, "@data")) {
      break
    }
    if (startsWith(line, "@attribute")) {
      metadata = c(metadata, line)
    }
    if (startsWith(line, "@frequency")) {
      freq = strsplit1(line, " ")[[2L]]
    }
    if (startsWith(line, "@horizon")) {
      horizon = as.integer(strsplit1(line, " ")[[2L]])
    }
    skip = skip + 1L
  }

  cat_cli({
    cli::cli_text("Reading tsf file:")
    cli::cli_li("frequency: {freq}")
    cli::cli_li("horizon: {horizon}")
  })

  metadata = setDT(tstrsplit(metadata, " ", fixed = TRUE, keep = c(2L, 3L)))
  setnames(metadata, c("name", "type"))
  col_names = metadata$name
  col_classes = map_values(metadata$type, c("string", "date", "numeric"), c("character", "character", "numeric"))

  dt = fread(
    file = file,
    sep = ":",
    header = FALSE,
    na.strings = "?",
    skip = skip,
    col.names = c(col_names, "value"),
    colClasses = c(col_classes, "character")
  )

  date_col = metadata["date", "name", on = "type"][[1L]]
  has_freq = length(freq) > 0L
  if (has_freq) {
    if (freq %in% high_frequencies) {
      set(dt, j = date_col, value = as.POSIXct(dt[[date_col]], tz = "UTC"))
    } else if (freq %in% low_frequencies) {
      set(dt, j = date_col, value = as.Date(dt[[date_col]]))
    } else {
      stopf("Invalid frequency.")
    }
  }

  value = NULL
  dt_long = dt[, list(value = strsplit1(value, ",")), by = col_names]
  dt_long["?", "value" := NA_character_, on = "value"]
  set(dt_long, j = "value", value = as.numeric(dt_long$value))
  set(dt, j = "value", value = NULL)
  dt = dt[dt_long, on = col_names]
  if (has_freq) {
    dt[, (date_col) := seq(first(get(date_col)), length.out = .N, by = tsf_to_seq(freq)), by = col_names]
    setattr(dt, "frequency", freq)
  }
  setattr(dt, "class", c("tsf", class(dt)))
  dt[]
}

#' @title Download tsf file from Zenodo
#'
#' @description
#' Downloads a tsf file from Zenodo using the provided record ID and dataset name.
#'
#' @param record_id (`integer(1)`)\cr
#'   The Zenodo record ID.
#' @param dataset_name (`character(1)`)\cr
#'   The name of the dataset to download.
#' @return ([data.table::data.table()]).
#'
#' @references
#' `r format_bib("godahewa2021monash")`
#'
#' @export
#' @examples
#' \dontrun{
#' dt = download_zenodo_record(record_id = 4656222, dataset_name = "m3_yearly_dataset")
#'
#' # optional renaming
#' setnames(dt, c("id", "date", "value"))
#'
#' # transform into single task
#' task = as_task_fcst(dt)
#'
#' # or split up for forecast learners that don't allow key columns
#' tasks = map(split(dt, by = "id"), function(x) {
#'   id = x[1L, id]
#'   x[, id := NULL]
#'   as_task_fcst(x, id = id)
#' })
#'
#' # benchmark
#' learners = lrns(c("fcst.auto_arima", "fcst.ets", "fcst.random_walk"))
#' resampling = rsmp("fcst.holdout", ratio = 0.8)
#' design = benchmark_grid(tasks, learners, resampling)
#' bmr = benchmark(design)
#' bmr$aggregate(msr("regr.rmse"))[, .(rmse = mean(regr.rmse)), by = learner_id]
#' }
download_zenodo_record = function(record_id = 4656222, dataset_name = "m3_yearly_dataset") {
  record_id = assert_count(record_id, positive = TRUE, coerce = TRUE)
  assert_string(dataset_name, min.chars = 1L)

  url = sprintf("https://zenodo.org/record/%i/files/%s.zip", record_id, dataset_name)
  td = tempfile()
  dir.create(td)
  on.exit(unlink(td, recursive = TRUE), add = TRUE)
  tf = file.path(td, "tempfile.zip")
  tryCatch(utils::download.file(url, tf, quiet = TRUE, mode = "wb"), error = function(e) {
    stopf("Failed to download TSF file from Zenodo with id: %s and name: %s", record_id, dataset_name)
  })
  file = utils::unzip(tf, exdir = td)
  if (tools::file_ext(file) != "tsf") {
    stopf("Downloaded file is not a TSF file: %s", file)
  }
  read_tsf(file)
}

tsf_to_seq = function(x) {
  switch(
    x,
    `4_seconds` = "4 secs",
    minutely = "min",
    `10_minutes` = "10 mins",
    `15_minutes` = "15 mins",
    half_hourly = "30 mins",
    hourly = "hour",
    daily = "day",
    weekly = "week",
    monthly = "month",
    quarterly = "quarter",
    yearly = "year"
  )
}
