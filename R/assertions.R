assert_frequency = function(x, .var.name = vname(x)) {
  assert(
    check_null(x),
    check_choice(x, c("secondly", "minutely", "hourly", "daily", "weekly", "monthly", "quarterly", "yearly")),
    check_count(x, positive = TRUE),
    .var.name = .var.name
  )
}

assert_freq = function(x, .var.name = vname(x)) {
  if (is.null(x)) {
    return(invisible())
  }
  if (test_count(x, positive = TRUE)) {
    storage.mode(x) = "integer"
    return(invisible(x))
  }
  choices = c("secondly", "minutely", "hourly", "daily", "weekly", "monthly", "quarterly", "yearly")
  if (test_choice(x, choices)) {
    return(invisible(x))
  }
  stopf("'%s' must be either: \n* `NULL`\n* a positive integer\n* one of: %s.", .var.name, toString(choices))
}

check_frequency2 = function(x) {
  # plus an integer before, can also be abbreivated (pmatch) with optional s suffix
  dt = c("day", "week", "month", "quarter", "year")
  dttm = c("sec", "min", "hour", "day", "DSTday", "week", "month", "quarter", "year")
  res = check_null(x)
  if (isTRUE(res)) {
    return(res)
  }
  res = check_count(x, positive = TRUE)
  if (isTRUE(res)) {
    return(res)
  }
  res = check_string(x, pattern = "^[1-9]+\\s+(secs?|mins?|hours?|days?|DSTdays?|weeks?|months?|quarters?|years?)$")
  if (!isTRUE(res)) {
    return(res)
  }
  TRUE
}
