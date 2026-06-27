check_freq = function(x) {
  if (is.null(x) || (test_number(x, finite = TRUE) && x > 0)) {
    return(TRUE)
  }
  if (!test_string(x)) {
    return("Must be a string, a positive number, or NULL")
  }
  valid_units = c("secs", "mins", "hours", "days", "DSTdays", "weeks", "months", "quarters", "years")
  msg = "Must be a seq()-compatible string (e.g. '1 month', 'day')"
  parts = strsplit1(x, " ")
  n = length(parts)
  if (n < 1L || n > 2L) {
    return(msg)
  }
  if (is.na(pmatch(parts[n], valid_units))) {
    return(msg)
  }
  if (n == 2L && !grepl("^[1-9][0-9]*$", parts[1L])) {
    return(msg)
  }
  TRUE
}

assert_freq = makeAssertionFunction(check_freq)

assert_regular_grid = function(dt, order_col, key_cols, freq) {
  if (length(key_cols) > 0L) {
    ok = dt[, list(.ok = check_regular_grid(get(order_col), freq)), by = key_cols]
    bad = ok[!ok$.ok]
    if (nrow(bad) > 0L) {
      error_input(
        "Cannot extend an irregular series into the future. Offending key group(s): %s. Use a regular order index (e.g. integer steps) or fill the gaps first.",
        toString(do.call(paste, c(bad[, key_cols, with = FALSE], list(sep = ":"))))
      )
    }
  } else if (!check_regular_grid(dt[[order_col]], freq)) {
    error_input(
      "Cannot extend an irregular series into the future. Use a regular order index (e.g. integer steps) or fill the gaps first."
    )
  }
  invisible(dt)
}

check_regular_grid = function(order, freq = NULL) {
  o = sort(order)
  n = length(o)
  if (n < 2L) {
    return(TRUE)
  }
  if (inherits(o, c("Date", "POSIXct", "POSIXlt"))) {
    step = if (is.character(freq)) freq else infer_freq(o)
    expected = c(o[1L], seq_order(o[1L], step, n - 1L))
    return(!anyNA(expected) && all(o == expected))
  }
  d = diff(o)
  d[1L] != 0 && all(d == d[1L])
}
