quantiles_to_levels = function(x) {
  sort(unique(round(abs(1 - 2 * x) * 100, 6)))
}

interval_bounds = function(quantiles, probs, alpha) {
  if (alpha <= 0 || alpha >= 1) {
    error_config("`alpha` must lie strictly between 0 and 1, but is %s.", alpha)
  }
  index = function(p) {
    i = which(abs(probs - p) < sqrt(.Machine$double.eps))
    if (length(i) != 1L) {
      error_input("Quantile %s is not among the predicted quantiles (%s).", p, str_collapse(probs))
    }
    i
  }
  list(lower = quantiles[, index(alpha / 2)], upper = quantiles[, index(1 - alpha / 2)])
}

strsplit1 = function(x, pattern) {
  strsplit(x, pattern, fixed = TRUE)[[1L]]
}

chrono_order = function(prediction, task) {
  order_col = task$col_roles$order
  if (length(order_col) == 0L) {
    return(seq_along(prediction$row_ids))
  }
  order_vals = task$data(rows = prediction$row_ids, cols = order_col)[[1L]]
  order(order_vals)
}

ordered_features = function(task, learner) {
  cols = names(learner$state$data_prototype) %??% learner$state$feature_names
  task$data(cols = intersect(cols, task$feature_names))
}

reorder_prediction = function(prediction, row_ids) {
  data = prediction$data
  ord = match(row_ids, data$row_ids)
  for (nm in names(data)) {
    x = data[[nm]]
    data[[nm]] = if (is.matrix(x)) {
      x[] = x[ord, , drop = FALSE]
      x
    } else if (length(x) == length(ord)) {
      x[ord]
    } else {
      x
    }
  }
  prediction$data = data
  prediction
}

graph_quantile_learners = function(graph) {
  learners = map(keep(graph$pipeops, inherits, "PipeOpLearner"), function(po) {
    if (inherits(po$learner, "GraphLearner")) graph_quantile_learners(po$learner$graph) else list(po$learner)
  })
  learners = unlist(learners, recursive = FALSE, use.names = FALSE)
  keep(learners, function(learner) "quantiles" %chin% learner$predict_types)
}

get_graph_quantile_field = function(graph, field, id) {
  learners = graph_quantile_learners(graph)
  if (length(learners) == 0L) {
    return()
  }
  values = map(learners, function(learner) learner[[field]])
  if (!every(values, function(value) identical(value, values[[1L]]))) {
    error_config("The learners in the graph of Learner '%s' use different `%s` values.", id, field)
  }
  values[[1L]]
}

set_graph_quantile_field = function(graph, field, value, id) {
  learners = graph_quantile_learners(graph)
  if (length(learners) == 0L) {
    error_config("Learner '%s' does not support predicting quantiles.", id)
  }
  walk(learners, function(learner) learner[[field]] = value)
}

graph_lags = function(graph) {
  lag_po = detect(graph$pipeops, function(po) inherits(po, "PipeOpFcstLags"))
  if (is.null(lag_po)) {
    return()
  }
  lag_po$param_set$values$lags
}

error_predict_newdata_fast = function(learner) {
  error_input(
    "Learner '%s' does not support predict_newdata_fast(). Use predict_newdata() or forecast() instead.",
    learner$id
  )
}

fcst_step_task = function(data, target, order_cols, key_cols, freq, feature_names) {
  set(data, j = "..row_id", value = seq_row(data))
  backend = DataBackendDataTable$new(data, "..row_id")
  task = as_task_fcst(backend, target = target, order = order_cols, key = key_cols, freq = freq)
  # preserve training feature col_roles so PipeOpTaskPreproc's layout check passes
  task$col_roles$feature = intersect(feature_names, names(data))
  task
}

fcst_finalize_prediction = function(prediction, task, target, order_cols, key_cols) {
  row_ids = task$row_ids
  data = task$data(rows = row_ids, cols = c(target, key_cols, order_cols))
  new_data = list(
    row_ids = row_ids,
    truth = data[[target]],
    extra = as.list(data[, c(key_cols, order_cols), with = FALSE]),
    col_roles = list(order = order_cols, key = key_cols)
  )
  # returning a Prediction bypasses the weights injection of as_prediction_data.list
  if ("weights_measure" %chin% task$properties) {
    new_data$weights = task$weights_measure[list(row_id = row_ids), on = "row_id", "weight"][[1L]]
  }
  prediction$data = insert_named(prediction$data, new_data)
  prediction
}

# the PipeOps with the "fcst_iterative" property, which must implement $shift() and $lookback
fcst_iterative_pipeops = function(graph) {
  pipeops = keep(graph$pipeops, function(po) "fcst_iterative" %chin% po$properties)
  missing_protocol = names(discard(pipeops, function(po) all(c("shift", "lookback") %chin% names(po))))
  if (length(missing_protocol) > 0L) {
    error_input(
      "PipeOps with the 'fcst_iterative' property must implement $shift() and $lookback, but %s do(es) not.",
      str_collapse(missing_protocol, quote = "'")
    )
  }
  pipeops
}

as_numeric_matrix = function(x) {
  x = as.matrix(x)
  if (is.logical(x)) {
    storage.mode(x) = "double"
  }
  x
}
