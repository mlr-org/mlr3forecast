score_grouped = function(score_fn, prediction, task, train_set = NULL, ...) {
  key_cols = task$col_roles$key
  key_data = task$data(rows = prediction$row_ids, cols = key_cols)
  groups = split(prediction$row_ids, key_data, drop = TRUE)

  train_groups = NULL
  if (!is.null(train_set)) {
    train_key_data = task$data(rows = train_set, cols = key_cols)
    train_groups = split(train_set, train_key_data, drop = TRUE)
    missing = setdiff(names(groups), names(train_groups))
    if (length(missing) > 0L) {
      error_input("Key group(s) %s have no observations in the training set.", str_collapse(missing, quote = "'"))
    }
  }

  scores = map_dbl(names(groups), function(nm) {
    pred = prediction$clone()$filter(groups[[nm]])
    score_fn(pred, task, train_set = train_groups[[nm]], ...)
  })
  mean(scores, na.rm = TRUE)
}

key_labels = function(dt, cols = names(dt)) {
  do.call(paste, c(dt[, cols, with = FALSE], sep = ":"))
}

fcst_invert_state = function(task) {
  state = list(truth = task$truth())
  key_cols = task$col_roles$key
  if (length(key_cols) > 0L) {
    layout = task$data(cols = c(key_cols, task$col_roles$order))
    set(layout, j = "..row_id", value = task$row_ids)
    state$layout = layout
  }
  state
}

fcst_assert_seen_keys = function(seen, dt, key_cols) {
  unseen = setdiff(unique(key_labels(dt, key_cols)), seen)
  if (length(unseen) > 0L) {
    error_input("Task has key group(s) not seen during training: %s.", str_collapse(unseen, quote = "'"))
  }
}

fcst_drop_incomplete = function(dt, feat_cols, key_cols) {
  kept = stats::na.omit(dt, cols = feat_cols)
  if (nrow(kept) == 0L) {
    error_input("The series is too short for the requested lags or window sizes.")
  }
  if (length(key_cols) > 0L && nrow(kept) < nrow(dt)) {
    dropped = unique(dt[, key_cols, with = FALSE])[!kept, on = key_cols]
    if (nrow(dropped) > 0L) {
      labels = key_labels(dropped)
      warning_input(
        "Dropped %i series too short for the requested lags/windows: %s.",
        nrow(dropped),
        str_collapse(labels, quote = "'")
      )
    }
  }
  kept
}
