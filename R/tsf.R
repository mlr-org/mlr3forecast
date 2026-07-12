#' @title Read tsf files
#'
#' @description
#' Parses a file located at `file` and returns a [data.table::data.table()].
#'
#' @param file (`character(1)`)\cr
#'   The path to the TSF file.
#' @return ([data.table::data.table()]) with class `"tsf"`. If the file contains a frequency or horizon, the
#'   `"frequency"` and `"horizon"` attributes are set, respectively.
#'
#' @references
#' `r format_bib("godahewa2021monash")`
#'
#' @export
#' @examples
#' file = system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast")
#' dt = read_tsf(file)
#' head(dt)
read_tsf = function(file) {
  assert_file(file, extension = "tsf")

  con = file(file, "r")
  on.exit(close(con), add = TRUE)
  skip = 1L
  metadata = character()
  freq = character()
  horizon = integer()

  repeat {
    line = readLines(con, n = 1L, warn = FALSE)
    if (length(line) == 0L) {
      stopf("No @data section found")
    }
    if (startsWith(line, "@data")) {
      break
    } else if (startsWith(line, "@attribute")) {
      metadata = c(metadata, line)
    } else if (startsWith(line, "@frequency")) {
      freq = strsplit1(line, " ")[2L]
    } else if (startsWith(line, "@horizon")) {
      horizon = as.integer(strsplit1(line, " ")[2L])
    }
    skip = skip + 1L
  }

  cat_cli({
    cli::cli_text("Reading tsf file:")
    if (length(freq) > 0L) {
      cli::cli_li("frequency: {freq}")
    }
    if (length(horizon) > 0L) {
      cli::cli_li("horizon: {horizon}")
    }
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
  has_date = !is.na(date_col)

  if (has_date && !has_freq) {
    stopf("Frequency is missing: a 'date' attribute requires a @frequency.")
  }

  if (has_freq) {
    if (freq %nin% names(tsf_frequencies)) {
      stopf("Invalid frequency %s, must be one of %s", freq, str_collapse(names(tsf_frequencies), quote = "'"))
    }
    if (has_date) {
      if (freq %in% names(tsf_high_frequencies)) {
        set(dt, j = date_col, value = as.POSIXct(dt[[date_col]], format = "%Y-%m-%d %H-%M-%S", tz = "UTC"))
      } else {
        set(dt, j = date_col, value = as.Date(dt[[date_col]], format = "%Y-%m-%d %H-%M-%S"))
      }
      if (anyNA(dt[[date_col]])) {
        stopf("Incorrect timestamp format. Specify your timestamps as YYYY-mm-dd HH-MM-SS")
      }
    }
  }

  value = NULL
  dt = dt[, list(value = strsplit1(value, ",")), by = col_names]
  dt["?", "value" := NA_character_, on = "value"]
  set(dt, j = "value", value = as.numeric(dt$value))
  if (has_freq) {
    if (has_date) {
      by_freq = tsf_to_seq(freq)
      dt[,
        (date_col) := {
          origin = get(date_col)[1L]
          c(origin, seq_order(origin, by_freq, .N - 1L))
        },
        by = col_names
      ]
    }
    setattr(dt, "frequency", freq)
  }
  if (length(horizon) > 0L) {
    setattr(dt, "horizon", horizon)
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
#' @return ([data.table::data.table()]) with class `"tsf"`. If the file contains a frequency or horizon, the
#'   `"frequency"` and `"horizon"` attributes are set, respectively.
#'
#' @references
#' `r format_bib("godahewa2021monash")`
#'
#' @export
#' @examples
#' \dontrun{
#' library(data.table)
#' dt = download_zenodo_record(record_id = 4656222, dataset_name = "m3_yearly_dataset")
#'
#' # optional renaming
#' setnames(dt, c("id", "date", "value"))
#'
#' # transform into single task
#' task = as_task_fcst(dt)
#'
#' # or split up for forecast learners that don't allow key columns
#' tasks = as_tasks_fcst(split(dt, by = "id", keep.by = FALSE))
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
  files = utils::unzip(tf, exdir = td)
  file = files[endsWith(files, ".tsf")]
  if (length(file) != 1L) {
    stopf("Expected exactly one TSF file in the downloaded archive, but found %i", length(file))
  }
  read_tsf(file)
}

tsf_high_frequencies = c(
  `4_seconds` = "4 secs",
  minutely = "min",
  `10_minutes` = "10 mins",
  `15_minutes` = "15 mins",
  half_hourly = "30 mins",
  hourly = "hour"
)

tsf_low_frequencies = c(
  daily = "day",
  weekly = "week",
  monthly = "month",
  quarterly = "quarter",
  yearly = "year"
)

tsf_frequencies = c(tsf_high_frequencies, tsf_low_frequencies)

tsf_to_seq = function(x) {
  tsf_frequencies[[x]]
}
