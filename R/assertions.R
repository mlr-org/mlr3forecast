check_freq = function(x) {
  if (is.null(x) || (test_number(x, finite = TRUE) && x > 0)) {
    return(TRUE)
  }
  if (!test_string(x)) {
    return("Must be a string, a positive number, or NULL")
  }
  valid_units = c("secs", "mins", "hours", "days", "DSTdays", "weeks", "months", "quarters", "years")
  parts = strsplit1(x, " ")
  n_parts = length(parts)
  if (n_parts < 1L || n_parts > 2L) {
    return("Must be a seq()-compatible string (e.g. '1 month', 'day')")
  }
  if (is.na(pmatch(parts[n_parts], valid_units))) {
    return("Must be a seq()-compatible string (e.g. '1 month', 'day')")
  }
  if (n_parts == 2L && !grepl("^[1-9][0-9]*$", parts[1L])) {
    return("Must be a seq()-compatible string (e.g. '1 month', 'day')")
  }
  TRUE
}

assert_freq = makeAssertionFunction(check_freq)
