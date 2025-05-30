read_tsf_ref = function(file) {
  assert_file(file)

  low_frequencies = c("daily", "weekly", "monthly", "quarterly", "yearly")
  low_freq_vals = c("1 day", "1 week", "1 month", "3 months", "1 year")
  high_frequencies = c("4_seconds", "minutely", "10_minutes", "half_hourly", "hourly")
  high_freq_vals = c("4 sec", "1 min", "10 min", "30 min", "1 hour")
  frequencies = c(low_frequencies, high_frequencies)
  freq_vals = c(low_freq_vals, high_freq_vals)

  freq_map = as.list(set_names(freq_vals, frequencies))

  if (is.character(file)) {
    file = file(file, "r")
    on.exit(close(file))
  }
  if (!inherits(file, "connection")) stopf("Argument 'file' must be a character string or connection.")
  if (!isOpen(file)) {
    open(file, "r")
    on.exit(close(file), add = TRUE)
  }

  col_types = list()
  metadata = list()

  line = readLines(file, n = 1L)

  while (length(line) > 0L && !grepl("^[[:space:]]*@data", line, perl = TRUE)) {
    if (grepl("^[[:space:]]*@", line, perl = TRUE)) {
      line = scan(text = line, what = character(), quiet = TRUE)

      if (line[1L] == "@attribute") {
        if (length(line) != 3L) stopf("Invalid meta-data specification.")
        col_types[[line[2L]]] = line[3L]
      } else if (length(line) != 2L) {
        stopf("Invalid meta-data specification.")
      } else {
        metadata[[substring(line[1L], 2L)]] = line[2L]
      }
    }
    line = readLines(file, n = 1L)
  }

  if (length(line) == 0L) stopf("Missing data section.")
  if (length(col_types) == 0L) stopf("Missing attribute section.")

  line = readLines(file, n = 1L)

  if (length(line) == 0L) stopf("Missing series information under data section.")

  data = list()

  while (length(line) != 0L) {
    row_data = strsplit(line, ":", fixed = TRUE)[[1L]]

    if (length(row_data) != length(col_types) + 1L) stopf("Missing attributes/values in series.")

    series = scan(text = row_data[length(row_data)], sep = ",", na.strings = "?", quiet = TRUE)
    if (all(is.na(series)))
      stopf(
        "All series values are missing. A given series should contains a set of comma separated numeric values. At least one numeric value should be there in a series."
      )

    for (col in seq_along(col_types)) {
      val = if (col_types[[col]] == "date") {
        if (is.null(metadata$frequency)) stopf("Frequency is missing.")
        if (metadata$frequency %in% high_frequencies) {
          start_time = as.POSIXct(row_data[[col]], format = "%Y-%m-%d %H-%M-%S", tz = "UTC")
        } else if (metadata$frequency %in% low_frequencies) {
          start_time = as.Date(row_data[[col]], format = "%Y-%m-%d %H-%M-%S")
        } else {
          stopf("Invalid frequency.")
        }

        if (is.na(start_time)) stopf("Incorrect timestamp format. Specify your timestamps as YYYY-mm-dd HH-MM-SS")
        seq(start_time, length.out = length(series), by = freq_map[[metadata$frequency]])
      } else if (col_types[[col]] == "numeric") {
        as.numeric(row_data[[col]])
      } else if (col_types[[col]] == "string") {
        as.character(row_data[[col]])
      } else {
        stopf("Invalid attribute type.")
      }

      if (is.null(data[[names(col_types)[[col]]]])) {
        data[[names(col_types)[[col]]]] = rep_len(val, length(series))
      } else {
        data[[names(col_types)[[col]]]] = c(data[[names(col_types)[[col]]]], rep_len(val, length(series)))
      }
    }

    data[["value"]] = c(data[["value"]], series)
    line = readLines(file, n = 1L)
  }

  setDT(data)
}
