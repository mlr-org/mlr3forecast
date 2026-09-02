assert_seen_keys = function(seen, dt, key_cols) {
  unseen = unique(dt[, key_cols, with = FALSE])[!seen, on = key_cols]
  if (nrow(unseen) > 0L) {
    error_input(
      "Task has key group(s) not seen during training: %s.",
      str_collapse(key_labels(unseen, key_cols), quote = "'")
    )
  }
}

assert_unmarshaled = function(learner) {
  if (isTRUE(learner$marshaled)) {
    error_input("Model is marshaled, call $unmarshal() first.")
  }
}

assert_has_model = function(learner) {
  if (is.null(learner$model)) {
    error_learner("No model stored.")
  }
  assert_unmarshaled(learner)
}

assert_fcst_prediction_col_roles = function(col_roles, extra) {
  assert_list(col_roles, names = "unique", .var.name = "col_roles")
  assert_names(names(col_roles), permutation.of = c("order", "key"), .var.name = "names of col_roles")
  col_roles = map(col_roles, assert_character, any.missing = FALSE, unique = TRUE)
  if (length(col_roles$order) > 1L) {
    error_learner_predict("There may only be up to one extra column with role 'order'")
  }
  if (length(intersect(col_roles$order, col_roles$key)) > 0L) {
    error_learner_predict("Extra column(s) may not have both the 'order' and the 'key' role")
  }
  assert_subset(unlist(col_roles, use.names = FALSE), names(extra), .var.name = "columns in col_roles")
  # canonical element order so downstream comparisons are representation-independent
  list(order = col_roles[["order"]], key = col_roles[["key"]])
}

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
    ok = dt[, list(.ok = test_regular_grid(get(order_cols), freq)), by = key_cols]
    bad = ok[!ok$.ok]
    if (nrow(bad) > 0L) {
      error_input(
        "Cannot extend an irregular series into the future. Offending key group(s): %s. Use a regular order index (e.g. integer steps) or fill the gaps first.",
        str_collapse(key_labels(bad, key_cols), quote = "'")
      )
    }
  } else if (!test_regular_grid(dt[[order_cols]], freq)) {
    error_input(
      "Cannot extend an irregular series into the future. Use a regular order index (e.g. integer steps) or fill the gaps first."
    )
  }
  invisible(dt)
}

test_regular_grid = function(order, freq = NULL) {
  o = sort(order)
  n = length(o)
  if (n < 2L) {
    return(TRUE)
  }
  if (inherits(o, c("Date", "POSIXct", "POSIXlt"))) {
    step = resolve_step(freq, o)
    expected = c(o[1L], seq_order(o[1L], step, n - 1L))
    return(!anyNA(expected) && all(o == expected))
  }
  d = diff(o)
  d[1L] != 0 && all(d == d[1L])
}
