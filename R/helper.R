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

graph_quantile_learners = function(graph) {
  learners = list()
  for (po in graph$pipeops) {
    if (inherits(po, "PipeOpLearner")) {
      learner = po$learner
      learners = c(
        learners,
        if (inherits(learner, "GraphLearner")) graph_quantile_learners(learner$graph) else list(learner)
      )
    }
  }
  keep(learners, function(learner) "quantiles" %chin% learner$predict_types)
}

get_graph_quantile_field = function(graph, field) {
  learners = graph_quantile_learners(graph)
  if (length(learners) == 0L) {
    return(NULL)
  }
  values = map(learners, function(learner) learner[[field]])
  if (!every(values, function(value) identical(value, values[[1L]]))) {
    error_config("The learners in Graph '%s' use different `%s` values.", graph$id %??% "", field)
  }
  values[[1L]]
}

set_graph_quantile_field = function(graph, field, value) {
  learners = graph_quantile_learners(graph)
  if (length(learners) == 0L) {
    error_config("Graph '%s' has no learner that supports quantiles.", graph$id %??% "")
  }
  walk(learners, function(learner) learner[[field]] = value)
}

as_numeric_matrix = function(x) {
  x = as.matrix(x)
  if (is.logical(x)) {
    storage.mode(x) = "double"
  }
  x
}
