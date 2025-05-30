#' @title Read TSF files
#'
#' @description
#' Parses a file located at `file` and returns a [data.table()].
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

  value = name = NULL
  date_col = metadata["date", name, on = "type"]
  if (freq %in% high_frequencies) {
    set(dt, j = date_col, value = as.POSIXct(dt[[date_col]], tz = "UTC"))
  } else if (freq %in% low_frequencies) {
    set(dt, j = date_col, value = as.Date(dt[[date_col]]))
  } else {
    stopf("Invalid frequency.")
  }

  dt_long = dt[, .(value = as.numeric(strsplit(value, ",", fixed = TRUE)[[1L]])), by = col_names]
  set(dt, j = "value", value = NULL)
  dt = dt[dt_long, on = col_names]
  dt[, (date_col) := seq(first(get(date_col)), length.out = .N, by = freq_map[[freq]]), by = col_names]
  dt[]
}

#' @title Download TSF file from Zenodo
#'
#' @description
#' Downloads a TSF file from Zenodo using the provided record ID and dataset name.
#'
#' @param record_id (`character(1)`) the Zenodo record ID.
#' @param dataset_name (`character(1)`) the name of the dataset to download.
#' @return ([data.table()]).
#' @export
download_zenodo_record = function(record_id = 4656222, dataset_name = "m3_yearly_dataset") {
  record_id = assert_count(record_id, positive = TRUE, coerce = TRUE)
  assert_string(dataset_name)

  url = sprintf("https://zenodo.org/record/%i/files/%s.zip", record_id, dataset_name)
  tmp = tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  tf = file.path(tmp, "tempfile.zip")
  tryCatch(download.file(url, tf, quiet = TRUE), error = function(e) {
    stopf("Failed to download TSF file from Zenodo with id: %s and name: %s", record_id, dataset_name)
  })
  file = utils::unzip(tf, exdir = tmp)
  read_tsf(file)
}
