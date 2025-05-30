#' @title Read TSF files
#'
#' @description
#' Parses a file located at `file` and returns a [data.table()].'
#'
#' @param file (`character(1)`) the path to the TSF file.
#' @return ([data.table()]).
#' @export
read_tsf = function(file) {
  assert_file(file)

  low_frequencies = c("daily", "weekly", "monthly", "quarterly", "yearly")
  low_freq_vals = c("1 day", "1 week", "1 month", "3 months", "1 year")
  high_frequencies = c("4_seconds", "minutely", "10_minutes", "half_hourly", "hourly")
  high_freq_vals = c("4 sec", "1 min", "10 min", "30 min", "1 hour")
  frequencies = c(low_frequencies, high_frequencies)
  freq_vals = c(low_freq_vals, high_freq_vals)
  freq_map = set_names(freq_vals, frequencies)

  con = file(file, "r")
  on.exit(close(con), add = TRUE)
  skip = 1L
  metadata = character()
  freq = character()
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
      freq = strsplit(line, " ", fixed = TRUE)[[1L]][[2L]]
    }
    skip = skip + 1L
  }
  if (length(freq) == 0L) {
    stopf("No @frequency section found")
  }

  metadata = setDT(tstrsplit(metadata, " ", fixed = TRUE, keep = c(2L, 3L)))
  setnames(metadata, c("name", "type"))
  col_names = metadata$name
  col_classes = map_values(metadata$type, c("string", "date", "numeric"), c("character", "character", "numeric"))

  dt = fread(
    file = file,
    sep = ":",
    header = FALSE,
    skip = skip,
    col.names = c(col_names, "value"),
    colClasses = c(col_classes, "character")
  )

  value = type = name = NULL
  date_col = metadata[type == "date", name]
  if (freq %in% high_frequencies) {
    dt[, (date_col) := as.POSIXct(get(date_col), format = "%Y-%m-%d %H-%M-%S", tz = "UTC")]
  } else if (freq %in% low_frequencies) {
    dt[, (date_col) := as.Date(get(date_col), format = "%Y-%m-%d %H-%M-%S")]
  } else {
    stopf("Invalid frequency.")
  }

  dt_long = dt[, .(value = as.numeric(strsplit(value, ",", fixed = TRUE)[[1L]])), by = col_names]
  dt[, value := NULL]
  dt = dt[dt_long, on = col_names]
  dt[, (date_col) := seq(first(get(date_col)), length.out = .N, by = freq_map[[freq]]), by = col_names]
  dt[]
}

download_zenodo_record = function(record_id = 4656222) {
  record_id = assert_int(record_id, coerce = TRUE)

  if (record_id %nin% names(mfr_ids)) {
    stopf(
      "The provided record_id is not valid. Please provide a valid record ID from the Monash Time Series Forecasting Repository." # nolint
    )
  }
  data_name = mfr_ids[[as.character(record_id)]]
  path = sprintf("https://zenodo.org/record/%i/files/%s.zip", record_id, data_name)
  tf = tempfile()
  on.exit(unlink(tf), add = TRUE)
  download.file(path, tf, quite = TRUE)
  file = utils::unzip(tf, list = TRUE)$Name
  con = unz(tf, file)
  browser()
}

# TODO: try to fetch from API
mfr_ids = c(
  "4656110" = "nn5_daily_dataset_with_missing_values",
  "4656117" = "nn5_daily_dataset_without_missing_values",
  "4656125" = "nn5_weekly_dataset",
  "4656193" = "m1_yearly_dataset",
  "4656154" = "m1_quarterly_dataset",
  "4656159" = "m1_monthly_dataset",
  "4656222" = "m3_yearly_dataset",
  "4656262" = "m3_quarterly_dataset",
  "4656298" = "m3_monthly_dataset",
  "4656335" = "m3_other_dataset",
  "4656379" = "m4_yearly_dataset",
  "4656410" = "m4_quarterly_dataset",
  "4656480" = "m4_monthly_dataset",
  "4656522" = "m4_weekly_dataset",
  "4656548" = "m4_daily_dataset",
  "4656589" = "m4_hourly_dataset",
  "4656103" = "tourism_yearly_dataset",
  "4656093" = "tourism_quarterly_dataset",
  "4656096" = "tourism_monthly_dataset",
  "4656022" = "car_parts_dataset_with_missing_values",
  "4656021" = "car_parts_dataset_without_missing_values",
  "4656014" = "hospital_dataset",
  "4654822" = "weather_dataset",
  "4654802" = "dominick_dataset",
  "4654833" = "fred_md_dataset",
  "4656144" = "solar_10_minutes_dataset",
  "4656151" = "solar_weekly_dataset",
  "4656027" = "solar_4_seconds_dataset",
  "4656032" = "wind_4_seconds_dataset",
  "4654773" = "sunspot_dataset_with_missing_values",
  "4654722" = "sunspot_dataset_without_missing_values",
  "4654909" = "wind_farms_minutely_dataset_with_missing_values",
  "4654858" = "wind_farms_minutely_dataset_without_missing_values",
  "4656069" = "elecdemand_dataset",
  "4656049" = "us_births_dataset",
  "4656058" = "saugeenday_dataset",
  "4656009" = "covid_deaths_dataset",
  "4656042" = "cif_2016_dataset",
  "4656072" = "london_smart_meters_dataset_with_missing_values",
  "4656091" = "london_smart_meters_dataset_without_missing_values",
  "4656080" = "kaggle_web_traffic_dataset_with_missing_values",
  "4656075" = "kaggle_web_traffic_dataset_without_missing_values",
  "4656664" = "kaggle_web_traffic_weekly_dataset",
  "4656132" = "traffic_hourly_dataset",
  "4656135" = "traffic_weekly_dataset",
  "4656140" = "electricity_hourly_dataset",
  "4656141" = "electricity_weekly_dataset",
  "4656626" = "pedestrian_counts_dataset",
  "4656719" = "kdd_cup_2018_dataset_with_missing_values",
  "4656756" = "kdd_cup_2018_dataset_without_missing_values",
  "4659727" = "australian_electricity_demand_dataset",
  "4663762" = "covid_mobility_dataset_with_missing_values",
  "4663809" = "covid_mobility_dataset_without_missing_values"
)
