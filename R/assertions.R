check_freq = function(x) {
  if (is.null(x) || (test_number(x, finite = TRUE) && x > 0)) {
    return(TRUE)
  }
  if (!test_string(x)) {
    return("Must be a string, a positive number, or NULL")
  }
  units = "sec|min|hour|day|DSTday|week|month|quarter|year"
  if (!grepl(sprintf("^([1-9][0-9]* )?(%s)s?$", units), x)) {
    return("Must be a seq()-compatible string (e.g. '1 month', 'day')")
  }
  TRUE
}

assert_freq = makeAssertionFunction(check_freq)

assert_regular_grid = function(dt, order_cols, key_cols, freq) {
  if (length(key_cols) > 0L) {
    ok = dt[, list(.ok = check_regular_grid(get(order_cols), freq)), by = key_cols]
    bad = ok[!ok$.ok]
    if (nrow(bad) > 0L) {
      error_input(
        "Cannot extend an irregular series into the future. Offending key group(s): %s. Use a regular order index (e.g. integer steps) or fill the gaps first.",
        toString(key_labels(bad, key_cols))
      )
    }
  } else if (!check_regular_grid(dt[[order_cols]], freq)) {
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
