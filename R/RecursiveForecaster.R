#' @title Recursive Forecast Learner
#'
#' @description
#' A [mlr3pipelines::GraphLearner] subclass for iterative one-step-ahead forecasting. Training is
#' fully delegated to the graph. At predict time the forecaster builds a combined task (training
#' history + test rows with `NA` targets) backed by a single mutable [data.table::data.table()],
#' iterates through the test rows in `(key, order)` order, and writes each prediction back into
#' the combined task's target column so that lag and rolling features for the next step reflect
#' the freshly predicted value.
#'
#' Can be constructed in two ways:
#' * **Simple**: `RecursiveForecaster$new(learner, lags = 1:3)` -- internally builds
#'   `po("fcst.lags", lags = lags) %>>% learner`.
#' * **Graph**: `RecursiveForecaster$new(graph)` -- takes an arbitrary
#'   [mlr3pipelines::Graph] or [mlr3pipelines::PipeOp].
#'
#' @section Target transformations:
#' A target transformation (e.g. [mlr_pipeops_fcst.targetdiff], [mlr3pipelines::PipeOpTargetMutate])
#' must *wrap* the forecaster, not be placed *inside* its graph. Wrap it with
#' [mlr3pipelines::ppl]`("targettrafo")` so the whole series is transformed once up front, the
#' recursion runs entirely on the transformed scale, and predictions are inverted once at the end:
#'
#' ```r
#' flrn = as_learner(ppl("targettrafo",
#'   graph = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:12),
#'   trafo_pipeop = po("fcst.targetdiff", lag = 1L)
#' ))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)  # predictions are on the original scale
#' ```
#'
#' Placing a [mlr3pipelines::PipeOpTargetTrafo] *inside* the graph is not supported and is rejected
#' at construction: it would entangle the transformation with the iterative lag/rolling feedback,
#' which read the original-scale backend, producing a train/predict scale mismatch.
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#'
#' task = tsk("airpassengers")
#' flrn = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
#' split = partition(task, ratio = 0.8)
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#'
#' # graph: custom preprocessing pipeline
#' graph = po("fcst.lags", lags = 1:3) %>>% lrn("regr.rpart")
#' flrn = RecursiveForecaster$new(graph)
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
RecursiveForecaster = R6::R6Class(
  "RecursiveForecaster",
  inherit = GraphLearner,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
    #'   A regression learner (when `lags` is provided) or a graph/PipeOp.
    #' @param lags (`integer()` | `NULL`)\cr
    #'   The lag values to use for creating lag features. If provided, `learner` is wrapped with
    #'   `po("fcst.lags", lags = lags)`. If `NULL`, `learner` must be a [mlr3pipelines::Graph] or
    #'   [mlr3pipelines::PipeOp].
    #' @param id (`character(1)` | `NULL`)\cr
    #'   Identifier, default `NULL` (auto-generated).
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings.
    #' @param predict_type (`character(1)` | `NULL`)\cr
    #'   The predict type, default `NULL`.
    #' @param clone_graph (`logical(1)`)\cr
    #'   Whether to clone the graph, default `TRUE`.
    initialize = function(
      learner,
      lags = NULL,
      id = NULL,
      param_vals = list(),
      predict_type = NULL,
      clone_graph = TRUE
    ) {
      if (!is.null(lags)) {
        assert_learner(as_learner(learner), task_type = "regr")
        lags = assert_integerish(lags, lower = 1L, any.missing = FALSE, coerce = TRUE)
        graph = po("fcst.lags", lags = lags) %>>% as_learner(learner, clone = TRUE)
      } else {
        graph = learner
      }

      super$initialize(
        graph = graph,
        id = id,
        param_vals = param_vals,
        task_type = "fcst",
        predict_type = predict_type,
        clone_graph = clone_graph
      )

      target_trafo_ids = keep(
        names(self$graph$pipeops),
        function(id) inherits(self$graph$pipeops[[id]], "PipeOpTargetTrafo")
      )
      if (length(target_trafo_ids) > 0L) {
        error_input(
          "Target transformations inside a RecursiveForecaster graph are not supported (found: %s). Apply the transformation outside the graph, or use DirectForecaster.",
          toString(target_trafo_ids)
        )
      }

      has_iterative = any(map_lgl(self$graph$pipeops, function(po) "fcst_iterative" %in% po$properties))
      if (!has_iterative) {
        warning_input(
          "Graph contains no PipeOps with the 'fcst_iterative' property (e.g., PipeOpFcstLags). Predictions will not use recursive forecasting."
        )
      }
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function(...) {
      super$print()
      lags = self$lags
      if (!is.null(lags)) {
        cat_cli(cli::cli_li("Lags: {lags}"))
      }
    }
  ),

  active = list(
    #' @field learner ([mlr3::Learner])\cr
    #' The base regression learner.
    learner = function(rhs) {
      assert_ro_binding(rhs)
      self$base_learner()
    },

    #' @field lags (`integer()` | `NULL`)\cr
    #' The lags used, or `NULL` if no [PipeOpFcstLags] is in the graph.
    lags = function(rhs) {
      assert_ro_binding(rhs)
      lag_po = private$.find_lag_po()
      if (is.null(lag_po)) {
        return()
      }
      lag_po$param_set$get_values()$lags
    },

    #' @field graph_model ([mlr3pipelines::Graph])\cr
    #' The trained [mlr3pipelines::Graph]. Overrides [mlr3pipelines::GraphLearner]'s `$graph_model` because the
    #' [RecursiveForecaster] model wraps the graph state in `$graph_state` alongside auxiliary metadata.
    graph_model = function(rhs) {
      assert_ro_binding(rhs)
      if (is.null(self$model)) {
        return(self$graph)
      }
      g = self$graph$clone(deep = TRUE)
      g$state = self$model$graph_state
      g
    }
  ),

  private = list(
    .train = function(task) {
      on.exit({
        self$graph$state = NULL
      })
      self$graph$train(task)
      graph_state = self$graph$state

      cols = unique(c(task$target_names, task$feature_names, task$col_roles$key, task$col_roles$order))
      state = list(
        graph_state = graph_state,
        train_data = task$data(cols = cols),
        target = task$target_names,
        key_cols = task$col_roles$key,
        order_cols = task$col_roles$order,
        feature_names = task$feature_names,
        freq = task$freq
      )
      class(state) = c("recursive_forecaster_model", class(state))
      state
    },

    .predict = function(task) {
      on.exit({
        self$graph$state = NULL
      })
      self$graph$state = self$model$graph_state

      iterative_pos = keep(self$graph$pipeops, function(po) "fcst_iterative" %in% po$properties)
      if (length(iterative_pos) == 0L) {
        prediction = self$graph$predict(task)
        return(prediction[[1L]])
      }

      target = self$model$target
      key_cols = self$model$key_cols
      order_cols = self$model$order_cols
      train_data = self$model$train_data

      test_cols = unique(c(target, intersect(self$model$feature_names, task$feature_names), key_cols, order_cols))
      test_data = task$data(cols = test_cols)

      # Drop training rows whose (key, order) overlap with the test set so the combined
      # backend has unique (key, order) — otherwise the lag/rolling joins return >1 row
      # per active row and downstream cbind/backend construction fails.
      join_cols = c(key_cols, order_cols)
      train_data = train_data[!test_data, on = join_cols]
      combined = rbindlist(list(train_data, test_data), use.names = TRUE, fill = TRUE)
      n_train = nrow(train_data)
      n_test = nrow(test_data)
      test_cids = seq.int(n_train + 1L, n_train + n_test)
      set(combined, i = test_cids, j = target, value = NA_real_)
      set(combined, j = "..rid", value = seq_len(nrow(combined)))

      backend = DataBackendDataTable$new(combined, "..rid")
      step_task = as_task_fcst(
        backend,
        target = target,
        order = order_cols,
        key = key_cols,
        freq = self$model$freq
      )
      # Preserve the feature col_roles from training so PipeOpTaskPreproc's layout
      # check passes (e.g., when the order column was also marked as a feature).
      step_task$col_roles$feature = intersect(self$model$feature_names, names(combined))

      ord = combined[test_cids, c(key_cols, order_cols, "..rid"), with = FALSE]
      setorderv(ord, c(key_cols, order_cols))
      active_cids = ord[["..rid"]]

      preds = vector("list", n_test)
      for (i in seq_len(n_test)) {
        cid = active_cids[i]
        step_task$row_roles$use = cid
        prediction = self$graph$predict(step_task)[[1L]]
        preds[[i]] = prediction
        set(combined, i = cid, j = target, value = prediction$response)
      }

      out = do.call(c, preds)
      out_row_ids = task$row_ids[active_cids - n_train]
      out_data = task$data(rows = out_row_ids, cols = c(target, key_cols, order_cols))
      out$data = insert_named(
        out$data,
        list(
          row_ids = out_row_ids,
          truth = out_data[[target]],
          extra = as.list(out_data[, c(key_cols, order_cols), with = FALSE])
        )
      )
      out
    },

    .find_lag_po = function() {
      lag_po_id = detect(names(self$graph$pipeops), function(id) inherits(self$graph$pipeops[[id]], "PipeOpFcstLags"))
      if (is.null(lag_po_id)) {
        return()
      }
      self$graph$pipeops[[lag_po_id]]
    }
  )
)

#' @export
#' @method marshal_model recursive_forecaster_model
marshal_model.recursive_forecaster_model = function(model, inplace = FALSE, ...) {
  gs = model$graph_state
  class(gs) = c("graph_learner_model", "list")
  marshaled_gs = marshal_model(gs, inplace = inplace, ...)
  if (!is_marshaled_model(marshaled_gs)) {
    return(model)
  }
  structure(
    list(
      marshaled = insert_named(model, list(graph_state = marshaled_gs)),
      packages = c("mlr3pipelines", "mlr3forecast")
    ),
    class = c(paste0(class(model), "_marshaled"), "marshaled")
  )
}

#' @export
#' @method unmarshal_model recursive_forecaster_model_marshaled
unmarshal_model.recursive_forecaster_model_marshaled = function(model, inplace = FALSE, ...) {
  m = model$marshaled
  m$graph_state = unmarshal_model(m$graph_state, inplace = inplace, ...)
  class(m$graph_state) = setdiff(class(m$graph_state), "graph_learner_model")
  structure(m, class = c("recursive_forecaster_model", "list"))
}
