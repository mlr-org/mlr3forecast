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
