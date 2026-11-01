#' @title Recursive Forecast Learner
#'
#' @description
#' A [mlr3pipelines::GraphLearner] for iterative one-step-ahead forecasting: a single model is fit,
#' then applied recursively, feeding each prediction back as a lag/rolling feature for the next step.
#'
#' Can be constructed in two ways:
#' * **Simple**: `RecursiveForecaster$new(learner, lags = 1:3)` -- internally builds
#'   `po("fcst.lags", lags = lags) %>>% learner`.
#' * **Graph**: `RecursiveForecaster$new(graph)` -- takes an arbitrary [mlr3pipelines::Graph] or
#'   [mlr3pipelines::PipeOp].
#'
#' All fields and methods of [mlr3pipelines::GraphLearner] are available, e.g. `$graph`, `$graph_model`,
#' `$base_learner()`, `$importance()`, `$validate`, and `$internal_valid_scores`.
#'
#' @section Target transformations:
#' A target transformation (e.g. [mlr_pipeops_fcst.targetdiff], [mlr3pipelines::PipeOpTargetMutate])
#' must *wrap* the forecaster, not be placed *inside* its graph.
#' Wrap it with [mlr3pipelines::ppl]`("targettrafo")` so the whole series is transformed once up front,
#' the recursion runs entirely on the transformed scale, and predictions are inverted once at the end:
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
#' Placing a [mlr3pipelines::PipeOpTargetTrafo] *inside* the graph is not supported and is rejected at construction.
#'
#' @section Prediction uncertainty:
#' Only the point forecast is fed back between steps, so `se`/`distr` uncertainty does not accumulate across horizons
#' and intervals are too narrow for `h > 1`.
#' For calibrated multi-step intervals, prefer [DirectForecaster].
#'
#' @section Validation and internal tuning:
#' If the wrapped graph contains a learner with the `"validation"` property,
#' the forecaster supports validation and internal tuning as well.
#' Configure it with [set_validate.RecursiveForecaster()], which sets the forecaster's `$validate` field
#' and routes the validation data to the graph's base learner.
#' A numeric ratio is split chronologically per key (via [`partition()`][mlr3::partition]),
#' so the validation set is always the most recent fraction of each series.
#' Note that the validation scores measure one-step-ahead (teacher-forced) accuracy,
#' not recursive multi-step accuracy.
#'
#' @export
#' @examplesIf mlr3misc::require_namespaces("rpart", quietly = TRUE)
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
RecursiveForecaster = R6Class(
  "RecursiveForecaster",
  inherit = GraphLearner,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
    #'   A regression learner (when `lags` is provided) or a graph/PipeOp.
    #' @param lags (`integer()` | `NULL`)\cr
    #'   The lag values to use for creating lag features.
    #'   If provided, `learner` is wrapped with `po("fcst.lags", lags = lags)`.
    #'   If `NULL`, `learner` must be a [mlr3pipelines::Graph] or [mlr3pipelines::PipeOp].
    #' @param id (`character(1)` | `NULL`)\cr
    #'   Identifier, default `NULL`, which uses the id of `learner` with the suffix `".recursive"`.
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
        learner = assert_learner(as_learner(learner), task_type = "regr")
        lags = assert_integerish(lags, lower = 1L, any.missing = FALSE, coerce = TRUE)
        graph = po("fcst.lags", lags = lags) %>>% learner
      } else {
        graph = as_graph(learner)
      }

      target_trafo_ids = names(keep(graph$pipeops, inherits, "PipeOpTargetTrafo"))
      if (length(target_trafo_ids) > 0L) {
        error_input(
          "Target transformations inside a RecursiveForecaster graph are not supported (found: %s). Wrap the forecaster with ppl(\"targettrafo\") instead.",
          str_collapse(target_trafo_ids, quote = "'")
        )
      }

      has_iterative = some(graph$pipeops, function(po) "fcst_iterative" %chin% po$properties)
      if (!has_iterative) {
        warning_input(
          "Graph contains no PipeOps with the 'fcst_iterative' property (e.g., PipeOpFcstLags). Predictions will not use recursive forecasting."
        )
      }

      super$initialize(
        graph,
        id = id,
        param_vals = param_vals,
        task_type = "fcst",
        predict_type = predict_type,
        clone_graph = clone_graph
      )
      if (is.null(id)) {
        self$id = paste0(if (inherits(learner, "Learner")) learner$id else self$id, ".recursive")
      }
      # GraphLearner advertises hotstart it does not implement, and "exogenous" comes with the fcst task type
      self$properties = setdiff(self$properties, c("exogenous", "hotstart_backward", "hotstart_forward"))
      self$packages = c("mlr3forecast", self$packages)
      self$man = "mlr3forecast::RecursiveForecaster"
    },

    #' @description
    #' Not supported, the inherited [mlr3pipelines::GraphLearner] method handles only regression and classification.
    #' Use `$predict_newdata()` or [forecast()] instead.
    #' @param newdata (ignored).
    #' @param task (ignored).
    predict_newdata_fast = function(newdata, task = NULL) {
      error_input(
        "Learner '%s' does not support predict_newdata_fast(). Use predict_newdata() or forecast() instead.",
        self$id
      )
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
    #' The untrained base regression learner of the graph.
    #' Use `$base_learner()` for a copy holding the trained model.
    learner = function(rhs) {
      assert_ro_binding(rhs)
      # base_learner() returns a trained clone, the live learner is held by the learner PipeOp
      detect(self$graph$pipeops, function(po) inherits(po, "PipeOpLearner"))$learner
    },

    #' @field quantiles (`numeric()`)\cr
    #' Numeric vector of probabilities to be used while predicting quantiles.
    #' Elements must be between 0 and 1, not missing and provided in ascending order.
    #' If only one quantile is provided, it is used as response.
    #' Otherwise, set `$quantile_response` to specify the response quantile.
    #' Set to `NULL` to reset both `$quantiles` and `$quantile_response`.
    quantiles = function(rhs) {
      if (missing(rhs)) {
        return(get_graph_quantile_field(self$graph, "quantiles", self$id))
      }
      set_graph_quantile_field(self$graph, "quantiles", rhs, self$id)
    },

    #' @field quantile_response (`numeric(1)`)\cr
    #' The quantile to be used as response.
    quantile_response = function(rhs) {
      if (missing(rhs)) {
        return(get_graph_quantile_field(self$graph, "quantile_response", self$id))
      }
      set_graph_quantile_field(self$graph, "quantile_response", rhs, self$id)
    },

    #' @field graph_model ([mlr3pipelines::Graph])\cr
    #' [mlr3pipelines::Graph] that is being wrapped.
    #' This [mlr3pipelines::Graph] contains a trained state after `$train()`.
    #' Read-only.
    graph_model = function(rhs) {
      assert_ro_binding(rhs)
      if (is.null(self$model)) {
        return(self$graph)
      }
      assert_unmarshaled(self)
      graph = self$graph$clone(deep = TRUE)
      graph$state = self$model$graph_state
      graph
    },

    #' @field native_model (any)\cr
    #' The fitted model.
    native_model = function(rhs) {
      assert_ro_binding(rhs)
      if (is.null(self$model)) {
        return()
      }
      assert_unmarshaled(self)
      self$base_learner()$native_model
    },

    #' @field lags (`integer()` | `NULL`)\cr
    #' The lags used, or `NULL` if no [PipeOpFcstLags] is in the graph.
    lags = function(rhs) {
      assert_ro_binding(rhs)
      lag_po = detect(self$graph$pipeops, function(po) inherits(po, "PipeOpFcstLags"))
      if (is.null(lag_po)) {
        return()
      }
      lag_po$param_set$get_values()$lags
    }
  ),

  private = list(
    deep_clone = function(name, value) {
      # GraphLearner's deep_clone skips the train task that Learner's clones
      if (name == "state" && !is.null(value$train_task)) {
        value$train_task = value$train_task$clone(deep = TRUE)
      }
      super$deep_clone(name, value)
    },

    .train = function(task) {
      graph_state = super$.train(task)

      cols = unique(c(task$target_names, task$feature_names, task$col_roles$key, task$col_roles$order))
      train_data = task$data(cols = cols)
      valid_task = task$internal_valid_task
      if (!is.null(valid_task)) {
        # validation rows are observed history: keep them in the recursion tail so test rows still
        # form the gap-free future grid after the training window
        valid_data = valid_task$data(cols = cols)
        valid_data = valid_data[!train_data, on = c(task$col_roles$key, task$col_roles$order)]
        train_data = rbindlist(list(train_data, valid_data), use.names = TRUE)
      }
      set_class(
        list(
          graph_state = graph_state,
          train_data = train_data,
          target = task$target_names,
          key_cols = task$col_roles$key,
          order_cols = task$col_roles$order,
          feature_names = task$feature_names,
          freq = task$freq
        ),
        c("recursive_forecaster_model", "list")
      )
    },

    .predict = function(task) {
      graph = self$graph
      on.exit({
        graph$state = NULL
      })
      graph$state = self$model$graph_state

      iterative_pos = keep(graph$pipeops, function(po) "fcst_iterative" %chin% po$properties)
      if (length(iterative_pos) == 0L) {
        out = graph$predict(task)[[1L]]
        # the inner learner does not set extra, so attach the time index and keys here
        cols = c(self$model$key_cols, self$model$order_cols)
        extra = as.list(task$data(rows = out$data$row_ids, cols = cols))
        col_roles = list(order = self$model$order_cols, key = self$model$key_cols)
        out$data = insert_named(out$data, list(extra = extra, col_roles = col_roles))
        return(out)
      }

      target = self$model$target
      key_cols = self$model$key_cols
      order_cols = self$model$order_cols
      train_data = self$model$train_data

      test_cols = unique(c(target, intersect(self$model$feature_names, task$feature_names), key_cols, order_cols))
      test_data = task$data(cols = test_cols)

      # drop training rows overlapping the test set so the combined backend has unique (key, order),
      # else lag/rolling joins return >1 row per active row
      join_cols = c(key_cols, order_cols)
      train_data = train_data[!test_data, on = join_cols]

      # test rows must form the gap-free future grid so positional shifts equal true step distance
      step = self$model$freq
      if (length(key_cols) > 0L) {
        origin = train_data[,
          list(..origin = max(order_cols), ..anchor = grid_anchor(order_cols, step)),
          by = key_cols,
          env = list(order_cols = order_cols, step = I(step), key_cols = I(key_cols))
        ]
        test_keys = test_data[, c(key_cols, order_cols), with = FALSE]
        grid_check = origin[test_keys, on = key_cols]
        if (anyNA(grid_check$..origin)) {
          error_input(
            "No training rows remain before the test set for %i key group(s).",
            uniqueN(grid_check[is.na(grid_check$..origin), key_cols, with = FALSE])
          )
        }
        grid_ok = grid_check[,
          list(..ok = {
            expected = seq_order(get("..origin")[1L], step, .N, get("..anchor")[1L])
            !anyNA(expected) && all(sort(order_cols) == expected)
          }),
          by = key_cols,
          env = list(order_cols = order_cols, step = I(step), key_cols = I(key_cols))
        ]
        bad = grid_ok[!grid_ok$..ok]
        if (nrow(bad) > 0L) {
          error_input(
            "Test rows must form the gap-free future grid following the training data. Offending key group(s): %s.",
            str_collapse(key_labels(bad, key_cols), quote = "'")
          )
        }
      } else {
        if (nrow(train_data) == 0L) {
          error_input("No training rows remain before the test set.")
        }
        origin = max(train_data[[order_cols]])
        expected = seq_order(origin, step, nrow(test_data), grid_anchor(train_data[[order_cols]], step))
        if (anyNA(expected) || !all(sort(test_data[[order_cols]]) == expected)) {
          error_input(
            "Test rows must form the gap-free future grid following the training data (origin %s, step %s).",
            format(origin),
            step
          )
        }
      }

      combined = rbindlist(list(train_data, test_data), use.names = TRUE, fill = TRUE)
      n_train = nrow(train_data)
      test_cids = n_train + seq_row(test_data)
      if (!is.double(combined[[target]])) {
        set(combined, j = target, value = as.numeric(combined[[target]]))
      }
      set(combined, i = test_cids, j = target, value = NA_real_)
      set(combined, j = "..row_id", value = seq_row(combined))

      backend = DataBackendDataTable$new(combined, "..row_id")
      step_task = as_task_fcst(
        backend,
        target = target,
        order = order_cols,
        key = key_cols,
        freq = self$model$freq
      )
      # preserve training feature col_roles so PipeOpTaskPreproc's layout check passes
      step_task$col_roles$feature = intersect(self$model$feature_names, names(combined))

      ord = combined[test_cids, c(key_cols, order_cols, "..row_id"), with = FALSE]
      setorderv(ord, c(key_cols, order_cols))
      active_cids = ord[["..row_id"]]

      # step s of a key depends only on its history and earlier steps, so keys predict jointly per step
      steps = if (length(key_cols) > 0L) rowidv(ord, cols = key_cols) else seq_row(ord)
      step_cids = split(active_cids, steps)
      preds = vector("list", length(step_cids))
      for (s in seq_along(step_cids)) {
        cids = step_cids[[s]]
        step_task$row_roles$use = cids
        prediction = graph$predict(step_task)[[1L]]
        preds[[s]] = prediction
        set(combined, i = cids, j = target, value = prediction$response[match(cids, prediction$row_ids)])
      }

      # concatenation is step-major; restore the task's row order
      out = reorder_prediction(do.call(c, preds), test_cids)
      out_row_ids = task$row_ids
      out_data = task$data(rows = out_row_ids, cols = c(target, key_cols, order_cols))
      new_data = list(
        row_ids = out_row_ids,
        truth = out_data[[target]],
        extra = as.list(out_data[, c(key_cols, order_cols), with = FALSE]),
        col_roles = list(order = order_cols, key = key_cols)
      )
      # returning a Prediction bypasses the weights injection of as_prediction_data.list
      if ("weights_measure" %chin% task$properties) {
        new_data$weights = task$weights_measure[list(row_id = out_row_ids), on = "row_id", "weight"][[1L]]
      }
      out$data = insert_named(out$data, new_data)
      out
    }
  )
)

#' @export
#' @method print recursive_forecaster_model
print.recursive_forecaster_model = function(x, ...) {
  cat_cli({
    cli::cli_text("<recursive_forecaster_model>")
    cli::cli_li("Target: {x$target}")
    cli::cli_li("Frequency: {x$freq}")
    cli::cli_li("Training rows: {nrow(x$train_data)}")
  })
  invisible(x)
}

#' @export
#' @method marshal_model recursive_forecaster_model
marshal_model.recursive_forecaster_model = function(model, inplace = FALSE, ...) {
  graph_state = model$graph_state
  # models trained with mlr3forecast 0.2.0 store the graph state without its class
  if (!inherits(graph_state, "graph_learner_model")) {
    graph_state = set_class(graph_state, c("graph_learner_model", class(graph_state)))
  }
  marshaled = marshal_model(graph_state, inplace = inplace, ...)
  if (!is_marshaled_model(marshaled)) {
    return(model)
  }
  set_class(
    list(
      marshaled = insert_named(model, list(graph_state = marshaled)),
      packages = c("mlr3pipelines", "mlr3forecast")
    ),
    c(paste0(class(model), "_marshaled"), "marshaled")
  )
}

#' @export
#' @method unmarshal_model recursive_forecaster_model_marshaled
unmarshal_model.recursive_forecaster_model_marshaled = function(model, inplace = FALSE, ...) {
  m = model$marshaled
  m$graph_state = unmarshal_model(m$graph_state, inplace = inplace, ...)
  set_class(m, c("recursive_forecaster_model", "list"))
}

#' @title Configure Validation for a RecursiveForecaster
#'
#' @description
#' Sets the `$validate` field of the forecaster, which controls *how* the validation data is constructed,
#' and configures the wrapped graph so its base learner uses it via [mlr3pipelines::set_validate.GraphLearner()].
#' See [mlr3::Learner] for the meaning of `validate`.
#' Errors if no learner in the graph supports validation.
#'
#' @param learner ([RecursiveForecaster])\cr
#'   The forecaster to configure.
#' @param validate (`numeric(1)` | `"predefined"` | `"test"` | `NULL`)\cr
#'   How to construct the internal validation data.
#' @param ... (any)\cr
#'   Passed to [mlr3pipelines::set_validate.GraphLearner()], e.g. `ids`, `args_all`, and `args`.
#'
#' @return [RecursiveForecaster], invisibly.
#'
#' @export
set_validate.RecursiveForecaster = function(learner, validate, ...) {
  # set_validate.GraphLearner() resets `validate` in an exit handler, which errors without validation support
  if ("validation" %nin% learner$properties) {
    error_input("Learner '%s' does not support validation.", learner$id)
  }
  NextMethod()
}

#' @export
#' @method default_fallback RecursiveForecaster
default_fallback.RecursiveForecaster = function(learner, ...) {
  default_fallback(learner$learner, ...)
}
