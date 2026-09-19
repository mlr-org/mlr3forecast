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
#' @include monash_datasets.R
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
      stopf("No @data section found.")
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
  cn = metadata$name
  cc = map_values(metadata$type, c("string", "date", "numeric"), c("character", "character", "numeric"))

  dt = fread(
    file = file,
    sep = ":",
    header = FALSE,
    na.strings = "?",
    skip = skip,
    col.names = c(cn, "value"),
    colClasses = c(cc, "character")
  )

  date_col = metadata["date", "name", on = "type"][[1L]]
  has_freq = length(freq) > 0L
  has_date = !is.na(date_col)

  if (has_date && !has_freq) {
    stopf("Frequency is missing: a 'date' attribute requires a @frequency.")
  }

  if (has_freq) {
    if (freq %nin% names(tsf_frequencies)) {
      stopf("Invalid frequency %s, must be one of %s.", freq, str_collapse(names(tsf_frequencies), quote = "'"))
    }
    if (has_date) {
      if (freq %chin% names(tsf_high_frequencies)) {
        set(dt, j = date_col, value = as.POSIXct(dt[[date_col]], format = "%Y-%m-%d %H-%M-%S", tz = "UTC"))
      } else {
        set(dt, j = date_col, value = as.Date(dt[[date_col]], format = "%Y-%m-%d %H-%M-%S"))
      }
      if (anyNA(dt[[date_col]])) {
        stopf("Incorrect timestamp format. Specify your timestamps as YYYY-mm-dd HH-MM-SS.")
      }
    }
  }

  value = NULL
  dt = dt[, list(value = strsplit1(value, ",")), by = cn]
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
        by = cn
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

#' @title Download a Monash Forecasting Repository dataset
#'
#' @description
#' Downloads a dataset of the Monash Forecasting Repository from Zenodo and parses it with [read_tsf()].
#' The catalog pins the Zenodo record for each dataset version listed at \url{https://forecastingdata.org/}.
#' Dataset IDs for incomplete variants end in `"_with_missing_values"`.
#'
#' @param dataset (`character(1)`)\cr
#'   The Monash dataset ID, e.g. `"m3_yearly"`.
#' @return ([data.table::data.table()]) with class `"tsf"`. If the file contains a frequency or horizon, the
#'   `"frequency"` and `"horizon"` attributes are set, respectively. For datasets whose file lacks a
#'   `@horizon` line, the `"horizon"` attribute is filled from the forecast horizon used in the Monash
#'   benchmark experiments, if one exists for that dataset.
#'
#' @references
#' `r format_bib("godahewa2021monash")`
#'
#' @export
#' @examples
#' \dontrun{
#' library(data.table)
#' dt = download_monash_dataset("m3_yearly")
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
download_monash_dataset = function(dataset) {
  info = resolve_monash_dataset(dataset)
  dt = download_zenodo_file(info$record_id, info$dataset_name)
  if (is.null(attr(dt, "horizon"))) {
    horizon = monash_horizon(info$dataset_name)
    if (!is.na(horizon)) {
      setattr(dt, "horizon", horizon)
    }
  }
  dt
}

#' @title Download tsf file from Zenodo
#'
#' @description
#' Deprecated, use [download_monash_dataset()] instead.
#' Downloads a tsf file from Zenodo using a Zenodo record ID and file name.
#'
#' @param record_id (`integer(1)`)\cr
#'   The Zenodo record ID, e.g. `4656222` for the M3 yearly dataset.
#' @param dataset_name (`character(1)`)\cr
#'   The name of the file to download, e.g. `"m3_yearly_dataset"`.
#' @return ([data.table::data.table()]) with class `"tsf"`, see [download_monash_dataset()].
#'
#' @keywords internal
#' @export
download_zenodo_record = function(record_id, dataset_name) {
  warn_deprecated("download_zenodo_record()")
  record_id = assert_count(record_id, positive = TRUE, coerce = TRUE)
  assert_string(dataset_name, min.chars = 1L)
  dt = download_zenodo_file(record_id, dataset_name)
  if (is.null(attr(dt, "horizon"))) {
    horizon = monash_horizon(dataset_name)
    if (!is.na(horizon)) {
      setattr(dt, "horizon", horizon)
    }
  }
  dt
}

download_zenodo_file = function(record_id, file) {
  url = sprintf("https://zenodo.org/record/%i/files/%s.zip", record_id, file)
  td = tempfile()
  dir.create(td)
  on.exit(unlink(td, recursive = TRUE), add = TRUE)
  tf = file.path(td, "tempfile.zip")
  tryCatch(utils::download.file(url, tf, quiet = TRUE, mode = "wb"), error = function(e) {
    stopf("Failed to download TSF file from Zenodo with id: %s and name: %s.", record_id, file)
  })
  files = utils::unzip(tf, exdir = td)
  tsf = files[endsWith(files, ".tsf")]
  if (length(tsf) != 1L) {
    stopf("Expected exactly one TSF file in the downloaded archive, but found %i.", length(tsf))
  }
  read_tsf(tsf)
}

monash_horizon = function(dataset_name) {
  name = sub("_dataset(_with(out)?_missing_values)?$", "", dataset_name)
  horizon = monash_horizons[name]
  if (is.na(horizon)) NA_integer_ else unname(horizon)
}

# forecast horizons used in the Monash benchmark experiments for datasets whose
# tsf file lacks a @horizon line, see experiments/fixed_horizon.R in
# https://github.com/rakshitha123/TSForecasting
monash_horizons = c(
  australian_electricity_demand = 336L,
  bitcoin = 30L,
  car_parts = 12L,
  covid_deaths = 30L,
  dominick = 8L,
  electricity_hourly = 168L,
  fred_md = 12L,
  hospital = 12L,
  kdd_cup_2018 = 168L,
  pedestrian_counts = 24L,
  rideshare = 168L,
  saugeenday = 30L,
  solar_10_minutes = 1008L,
  sunspot = 30L,
  temperature_rain = 30L,
  traffic_hourly = 168L,
  us_births = 30L,
  vehicle_trips = 30L,
  weather = 30L
)

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
