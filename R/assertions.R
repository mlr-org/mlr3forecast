assert_has_backend = function(task) {
  if (is.null(task$backend)) {
    stopf(
      "The backend of Task '%s' has been removed. Set `store_backends` to `TRUE` during model fitting to conserve it.",
      task$id
    )
  }
}

assert_frequency = function(x) {
  assert(
    check_null(x),
    check_choice(x, c("secondly", "minutely", "hourly", "daily", "weekly", "monthly", "quarterly", "yearly")),
    check_count(x, positive = TRUE)
  )
}

check_frequency = function(x) {
  # plus an integer before, can also be abbreivated (pmatch) with optional s suffix
  dt = c("day", "week", "month", "quarter", "year")
  dttm = c("sec", "min", "hour", "day", "DSTday", "week", "month", "quarter", "year")
  res = check_null(x)
  if (isTRUE(x)) {
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
