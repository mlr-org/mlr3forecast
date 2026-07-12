score_grouped = function(score_fn, prediction, task, train_set = NULL, ...) {
  key_cols = task$col_roles$key
  key_data = task$data(rows = prediction$row_ids, cols = key_cols)
  set(key_data, j = "..row_id", value = prediction$row_ids)
  groups = key_data[, list(.rows = list(..row_id)), by = key_cols]

  train_groups = NULL
  if (!is.null(train_set)) {
    train_key_data = task$data(rows = train_set, cols = key_cols)
    set(train_key_data, j = "..row_id", value = train_set)
    train_groups = train_key_data[, list(.train_rows = list(..row_id)), by = key_cols]
    missing = groups[!train_groups, on = key_cols]
    if (nrow(missing) > 0L) {
      error_input(
        "Key group(s) %s have no observations in the training set.",
        str_collapse(key_labels(missing, key_cols), quote = "'")
      )
    }
    groups = train_groups[groups, on = key_cols]
  }

  scores = map_dbl(seq_row(groups), function(i) {
    pred = prediction$clone()$filter(groups$.rows[[i]])
    train_rows = if (is.null(train_set)) NULL else groups$.train_rows[[i]]
    score_fn(pred, task, train_set = train_rows, ...)
  })
  mean(scores, na.rm = TRUE)
}

key_labels = function(dt, cols = names(dt)) {
  do.call(paste, c(dt[, cols, with = FALSE], sep = ":"))
}

key_ids = function(dt, cols = names(dt)) {
  labels = key_labels(dt, cols)
  dup = duplicated(labels) | duplicated(labels, fromLast = TRUE)
  if (any(dup)) {
    keys = dt[, cols, with = FALSE]
    hashes = map_chr(seq_row(keys), function(i) calculate_hash(map(keys[i], as.character)))
    labels[dup] = sprintf("%s#%s", labels[dup], hashes[dup])
  }
  labels
}

key_table = function(dt, cols) {
  keys = unique(dt[, cols, with = FALSE])
  set(keys, j = ".label", value = key_ids(keys, cols))
  keys
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
  unseen = unique(dt[, key_cols, with = FALSE])[!seen, on = key_cols]
  if (nrow(unseen) > 0L) {
    error_input(
      "Task has key group(s) not seen during training: %s.",
      str_collapse(key_labels(unseen, key_cols), quote = "'")
    )
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
