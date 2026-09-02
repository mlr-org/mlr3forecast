quantiles_to_levels = function(x) {
  x = x[x != 0.5]
  sort(unique(round(abs(1 - 2 * x) * 100, 6)))
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

graph_template_learner = function(graph) {
  pos = keep(graph$pipeops, function(po) inherits(po, "PipeOpLearner"))
  if (length(pos) != 1L) {
    error_input("Graph '%s' has no unique PipeOpLearner.", graph$id %??% "")
  }
  learner = pos[[1L]]$learner
  if (inherits(learner, "GraphLearner")) graph_template_learner(learner$graph) else learner
}

as_numeric_matrix = function(x) {
  x = as.matrix(x)
  if (is.logical(x)) {
    storage.mode(x) = "double"
  }
  x
}
