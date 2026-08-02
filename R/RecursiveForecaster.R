#' @title Recursive Forecast Learner
#'
#' @description
#' A [mlr3::Learner] for iterative one-step-ahead forecasting: a single model is fit, then applied recursively,
#' feeding each prediction back as a lag/rolling feature for the next step.
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
#' at construction.
#'
#' @section Prediction uncertainty:
#' Only the point forecast is fed back between steps, so `se`/`distr` uncertainty does not accumulate across horizons
#' and intervals are too narrow for `h > 1`. For calibrated multi-step intervals, prefer [DirectForecaster].
#'
#' @section Validation and internal tuning:
#' If the wrapped graph contains a learner with the `"validation"` property, the forecaster supports
#' validation and internal tuning as well. Configure it with [mlr3::set_validate()], which sets the
#' forecaster's `$validate` field and routes the validation data to the graph's base learner.
#' A numeric ratio is split chronologically per key (via [`partition()`][mlr3::partition]), so the
#' validation set is always the most recent fraction of each series. Note that the validation scores
#' measure one-step-ahead (teacher-forced) accuracy, not recursive multi-step accuracy.
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
RecursiveForecaster = R6Class(
  "RecursiveForecaster",
  inherit = Learner,
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
        graph = as_graph(learner)
      }

      private$.learner = GraphLearner$new(graph, task_type = "regr", clone_graph = clone_graph)
      if (length(param_vals)) {
        private$.learner$param_set$values = insert_named(private$.learner$param_set$values, param_vals)
      }

      target_trafo_ids = keep(
        names(private$.learner$graph$pipeops),
        function(id) inherits(private$.learner$graph$pipeops[[id]], "PipeOpTargetTrafo")
      )
      if (length(target_trafo_ids) > 0L) {
        error_input(
          "Target transformations inside a RecursiveForecaster graph are not supported (found: %s). Wrap the forecaster with ppl(\"targettrafo\") instead.",
          str_collapse(target_trafo_ids, quote = "'")
        )
      }

      has_iterative = any(map_lgl(private$.learner$graph$pipeops, function(po) "fcst_iterative" %chin% po$properties))
      if (!has_iterative) {
        warning_input(
          "Graph contains no PipeOps with the 'fcst_iterative' property (e.g., PipeOpFcstLags). Predictions will not use recursive forecasting."
        )
      }

      super$initialize(
        id = id %??% private$.learner$id,
        task_type = "fcst",
        predict_types = private$.learner$predict_types,
        feature_types = private$.learner$feature_types,
        # GraphLearner advertises hotstart support it does not implement, so it must not be re-advertised
        properties = setdiff(private$.learner$properties, c("hotstart_backward", "hotstart_forward")),
        packages = c("mlr3forecast", private$.learner$packages),
        man = private$.learner$man
      )
      private$.predict_type = private$.learner$predict_type
      if (!is.null(predict_type)) self$predict_type = predict_type
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
    },

    #' @description
    #' Marshal the learner's model.
    #' @param ... (any)\cr
    #'   Additional arguments passed to [`mlr3::marshal_model()`].
    marshal = function(...) {
      learner_marshal(.learner = self, ...)
    },

    #' @description
    #' Unmarshal the learner's model.
    #' @param ... (any)\cr
    #'   Additional arguments passed to [`mlr3::unmarshal_model()`].
    unmarshal = function(...) {
      learner_unmarshal(.learner = self, ...)
    },

    #' @description
    #' The importance scores of the base learner, if it supports them.
    #' @return Named `numeric()`.
    importance = function() {
      private$.with_graph_state(function() private$.learner$importance())
    },

    #' @description
    #' The selected features of the base learner, if it supports them.
    #' @return `character()`.
    selected_features = function() {
      private$.with_graph_state(function() private$.learner$selected_features())
    },

    #' @description
    #' The out-of-bag error of the base learner, if it supports it.
    #' @return `numeric(1)`.
    oob_error = function() {
      private$.with_graph_state(function() private$.learner$oob_error())
    }
  ),

  active = list(
    #' @field learner ([mlr3::Learner])\cr
    #' The base regression learner.
    learner = function(rhs) {
      assert_ro_binding(rhs)
      private$.learner$base_learner()
    },

    #' @field native_model (any)\cr
    #' The fitted model.
    native_model = function(rhs) {
      assert_ro_binding(rhs)
      if (is.null(self$model)) {
        return()
      }
      self$model$graph_state[[self$learner$id]]$model
    },

    #' @field lags (`integer()` | `NULL`)\cr
    #' The lags used, or `NULL` if no [PipeOpFcstLags] is in the graph.
    lags = function(rhs) {
      assert_ro_binding(rhs)
      lag_po = detect(private$.learner$graph$pipeops, function(po) inherits(po, "PipeOpFcstLags"))
      if (is.null(lag_po)) {
        return()
      }
      lag_po$param_set$get_values()$lags
    },

    #' @template field_param_set
    param_set = function(rhs) {
      param_set = private$.learner$param_set
      if (!missing(rhs) && !identical(rhs, param_set)) {
        error_input("param_set is read-only.")
      }
      param_set
    },

    #' @field marshaled (`logical(1)`)\cr
    #' Whether the learner's model is currently in marshaled form.
    marshaled = function() {
      learner_marshaled(self)
    },

    #' @field validate (`numeric(1)` | `"predefined"` | `"test"` | `NULL`)\cr
    #' How to construct the internal validation data. Use [mlr3::set_validate()] to also configure
    #' the wrapped graph.
    validate = function(rhs) {
      if (!missing(rhs)) {
        if ("validation" %nin% private$.learner$properties) {
          error_input("None of the PipeOps in the graph of Learner '%s' supports validation.", self$id)
        }
        private$.validate = assert_validate(rhs)
      }
      private$.validate
    },

    #' @field internal_valid_scores (named `list()` | `NULL`)\cr
    #' The internal validation scores extracted from the wrapped graph, or `NULL` if no validation
    #' was done.
    internal_valid_scores = function(rhs) {
      assert_ro_binding(rhs)
      self$state$internal_valid_scores
    },

    #' @field internal_tuned_values (named `list()` | `NULL`)\cr
    #' The internally tuned values extracted from the wrapped graph, or `NULL` if no internal
    #' tuning was done.
    internal_tuned_values = function(rhs) {
      assert_ro_binding(rhs)
      self$state$internal_tuned_values
    },

    #' @field predict_type (`character(1)`)\cr
    #' Stores the currently active predict type.
    predict_type = function(rhs) {
      if (missing(rhs)) {
        return(private$.predict_type)
      }
      if (rhs %nin% self$predict_types) {
        error_input("Learner '%s' does not support predict type '%s'.", self$id, rhs)
      }
      private$.learner$predict_type = rhs
      private$.predict_type = rhs
    }
  ),

  private = list(
    .learner = NULL,
    .predict_type = NULL,
    .validate = NULL,

    deep_clone = function(name, value) {
      switch(name, .learner = value$clone(deep = TRUE), super$deep_clone(name, value))
    },

    .pos_with_property = function(property) {
      keep(private$.learner$graph$pipeops, function(po) property %chin% po$properties)
    },

    .with_graph_state = function(fn) {
      assert_has_model(self)
      graph = private$.learner$graph
      on.exit({
        graph$state = NULL
      })
      graph$state = self$model$graph_state
      fn()
    },

    .extract_internal_valid_scores = function() {
      if ("validation" %nin% self$properties) {
        return(NULL)
      }
      scores = unlist(
        imap(private$.pos_with_property("validation"), function(po, id) {
          self$model$graph_state[[id]]$internal_valid_scores
        }),
        recursive = FALSE
      )
      if (length(scores)) scores else named_list()
    },

    .extract_internal_tuned_values = function() {
      if ("internal_tuning" %nin% self$properties) {
        return(NULL)
      }
      values = unlist(
        imap(private$.pos_with_property("internal_tuning"), function(po, id) {
          self$model$graph_state[[id]]$internal_tuned_values
        }),
        recursive = FALSE
      )
      if (length(values)) values else named_list()
    },

    .base_learner = function(recursive = Inf) {
      if (recursive <= 0L) {
        return(self)
      }
      if (is.null(self$model)) {
        return(private$.learner$base_learner(recursive - 1L))
      }
      private$.with_graph_state(function() private$.learner$base_learner(recursive - 1L))
    },

    .train = function(task) {
      if (!is.null(get0("validate", self))) {
        uses_valid = some(private$.pos_with_property("validation"), function(po) !is.null(po$validate))
        if (!uses_valid) {
          lg$warn("Learner '%s' specifies a validation set, but none of its PipeOps use it.", self$id)
        }
      }

      graph = private$.learner$graph
      on.exit({
        graph$state = NULL
      })
      graph$train(task)
      graph_state = graph$state

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
      state = list(
        graph_state = graph_state,
        train_data = train_data,
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
      graph = private$.learner$graph
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
      step = resolve_step(self$model$freq, train_data[[order_cols]])
      if (length(key_cols) > 0L) {
        origin = train_data[, list(.origin = max(get(order_cols))), by = key_cols]
        grid_check = origin[test_data[, c(key_cols, order_cols), with = FALSE], on = key_cols]
        if (anyNA(grid_check$.origin)) {
          error_input(
            "No training rows remain before the test set for %i key group(s).",
            uniqueN(grid_check[is.na(grid_check$.origin), key_cols, with = FALSE])
          )
        }
        grid_ok = grid_check[,
          list(.ok = {
            expected = seq_order(get(".origin")[1L], step, .N)
            !anyNA(expected) && all(sort(get(order_cols)) == expected)
          }),
          by = key_cols
        ]
        bad = grid_ok[!grid_ok$.ok]
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
        expected = seq_order(origin, step, nrow(test_data))
        if (anyNA(expected) || !all(sort(test_data[[order_cols]]) == expected)) {
          error_input(
            "Test rows must form the gap-free future grid following the training data (origin %s, freq %s).",
            format(origin),
            step
          )
        }
      }

      combined = rbindlist(list(train_data, test_data), use.names = TRUE, fill = TRUE)
      n_train = nrow(train_data)
      n_test = nrow(test_data)
      test_cids = seq.int(n_train + 1L, n_train + n_test)
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

      preds = vector("list", n_test)
      for (i in seq_len(n_test)) {
        cid = active_cids[i]
        step_task$row_roles$use = cid
        prediction = graph$predict(step_task)[[1L]]
        preds[[i]] = prediction
        set(combined, i = cid, j = target, value = prediction$response)
      }

      out = do.call(c, preds)
      out_row_ids = task$row_ids[active_cids - n_train]
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
    if (!is.null(x$freq)) {
      cli::cli_li("Frequency: {x$freq}")
    }
    cli::cli_li("Training rows: {nrow(x$train_data)}")
  })
  invisible(x)
}

#' @export
#' @method marshal_model recursive_forecaster_model
marshal_model.recursive_forecaster_model = function(model, inplace = FALSE, ...) {
  gs = model$graph_state
  class(gs) = c("graph_learner_model", "list")
  marshaled_gs = marshal_model(gs, inplace = inplace, ...)
  if (!is_marshaled_model(marshaled_gs)) {
    return(model)
  }
  set_class(
    list(
      marshaled = insert_named(model, list(graph_state = marshaled_gs)),
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
  class(m$graph_state) = setdiff(class(m$graph_state), "graph_learner_model")
  set_class(m, c("recursive_forecaster_model", "list"))
}

#' @title Configure Validation for a RecursiveForecaster
#'
#' @description
#' Sets the `$validate` field of the forecaster, which controls *how* the validation data is
#' constructed (see [mlr3::Learner]), and configures the wrapped graph so its base learner uses it
#' (via [mlr3pipelines::set_validate.GraphLearner()], the inner PipeOps receive `"predefined"`).
#'
#' @param learner ([RecursiveForecaster])\cr
#'   The forecaster to configure.
#' @param validate (`numeric(1)` | `"predefined"` | `"test"` | `NULL`)\cr
#'   How to construct the internal validation data.
#' @param ids (`character()` | `NULL`)\cr
#'   The ids of the PipeOps for which to enable validation, forwarded to
#'   [mlr3pipelines::set_validate.GraphLearner()]. Defaults to the base learner.
#' @param args_all (named `list()`)\cr
#'   Arguments passed to all `set_validate()` calls of the affected PipeOps.
#' @param args (named `list()` of named `list()`s)\cr
#'   Arguments passed to the `set_validate()` calls of specific PipeOps, named by their ids.
#' @param ... (any)\cr
#'   Further arguments passed to [mlr3pipelines::set_validate.GraphLearner()].
#'
#' @return [RecursiveForecaster], invisibly.
#'
#' @export
set_validate.RecursiveForecaster = function(learner, validate, ids = NULL, args_all = list(), args = list(), ...) {
  if ("validation" %nin% learner$properties) {
    error_input("Learner '%s' does not support validation.", learner$id)
  }
  prev_validate = learner$validate
  on.exit({
    learner$validate = prev_validate
  })
  learner$validate = validate
  set_validate(
    get_private(learner)$.learner,
    validate = if (is.null(validate)) NULL else "predefined",
    ids = ids,
    args_all = args_all,
    args = args,
    ...
  )
  on.exit()
  invisible(learner)
}
