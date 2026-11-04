#' @title Direct Multi-Step Forecast Learner
#'
#' @description
#' Trains a separate model for each forecast horizon.
#' Unlike [RecursiveForecaster], predictions do not feed back into subsequent steps (no error accumulation).
#'
#' Can be constructed in two ways, like [RecursiveForecaster]:
#' * **Simple**: `DirectForecaster$new(learner, lags = 1:3, horizons = 12)` -- internally builds
#'   `po("fcst.lags", lags = lags) %>>% learner`.
#' * **Graph**: `DirectForecaster$new(graph, horizons = 12)` -- takes a [mlr3pipelines::Graph] or
#'   [mlr3pipelines::PipeOp] that creates its own lag or rolling features,
#'   so the same graph works with both forecasters.
#'
#' @section Iterative features:
#' The model for horizon `h` is trained on a copy of the graph in which every PipeOp with the `"fcst_iterative"`
#' property, e.g. [PipeOpFcstLags] or [PipeOpFcstRolling], is shifted `h - 1` steps into the past via its `$shift()`
#' method.
#' For example, base lags `1:3` become lags `h:(h + 2)`, so at prediction time only observed values are needed.
#' Tune the base values via the PipeOp's parameters, e.g. `fcst.lags.lags`.
#' Only the last `$lookback` observations of each series are kept for prediction,
#' or all of them for an expanding window.
#' At predict time the graph is evaluated with the trained state of each horizon,
#' so iterative PipeOps must store the settings their predict step needs in their state.
#'
#' @section Wrapped learner:
#' `$graph` is the wrapped graph and `$base_learner()` its base learner, like for [RecursiveForecaster].
#' Both are the untrained templates shared by all horizons, the trained graph of each horizon is in `$graph_model`.
#'
#' @export
#' @examplesIf mlr3misc::require_namespaces("rpart", quietly = TRUE)
#' \donttest{
#' library(mlr3pipelines)
#'
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
#'
#' # simple: one model per horizon
#' flrn = DirectForecaster$new(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#'
#' # graph: lag and rolling features, shifted per horizon
#' graph = po("fcst.lags", lags = 1:3) %>>% po("fcst.rolling", window_sizes = 6L) %>>% lrn("regr.rpart")
#' flrn = DirectForecaster$new(graph, horizons = length(split$test))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
#' }
DirectForecaster = R6Class(
  "DirectForecaster",
  inherit = Learner,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
    #'   A regression learner or a graph/PipeOp.
    #' @param lags (`integer()` | `NULL`)\cr
    #'   The base lag values.
    #'   If provided, `po("fcst.lags", lags = lags)` is added in front of `learner`,
    #'   and its parameter `fcst.lags.lags` can be tuned via [mlr3tuning::AutoTuner].
    #'   If `NULL`, the graph should contain its own lag or rolling features.
    #' @param horizons (`integer()`)\cr
    #'   Either a single integer `H` (expanded to `1:H`) or an integer vector of specific horizons.
    #'   One model is trained per horizon. At predict time each test row is routed to the model
    #'   matching its step-distance from the end of training, so with specific horizons (e.g.
    #'   `c(2L, 4L, 6L)`) the test set may only contain rows at those exact steps ahead.
    #' @param id (`character(1)` | `NULL`)\cr
    #'   Identifier, default `NULL`, which uses the id of `learner` with the suffix `".direct"`.
    #' @param param_vals (named `list()`)\cr
    #'   Hyperparameter values applied to every horizon model. Per-horizon hyperparameters are not
    #'   currently supported.
    #' @param predict_type (`character(1)` | `NULL`)\cr
    #'   The predict type, default `NULL`.
    #' @param clone_graph (`logical(1)`)\cr
    #'   Whether to clone the graph, default `TRUE`.
    #'   If `lags` is provided, a new graph is built in any case.
    initialize = function(
      learner,
      lags = NULL,
      horizons,
      id = NULL,
      param_vals = list(),
      predict_type = NULL,
      clone_graph = TRUE
    ) {
      lags = assert_integerish(
        lags,
        lower = 1L,
        any.missing = FALSE,
        min.len = 1L,
        unique = TRUE,
        coerce = TRUE,
        null.ok = TRUE
      )
      horizons = assert_integerish(
        horizons,
        lower = 1L,
        any.missing = FALSE,
        min.len = 1L,
        unique = TRUE,
        coerce = TRUE
      )
      if (length(horizons) == 1L) {
        horizons = seq_len(horizons)
      }
      private$.horizons = horizons

      if (!inherits(learner, c("Graph", "PipeOp"))) {
        learner = assert_learner(as_learner(learner), task_type = "regr")
      }
      graph = as_graph(learner)
      if (!is.null(lags)) {
        if ("fcst.lags" %chin% graph$ids()) {
          error_input(
            "The graph already contains a PipeOp with id 'fcst.lags', so `lags` cannot add another one. Either drop `lags` or remove that PipeOp from the graph."
          )
        }
        graph = po("fcst.lags", lags = lags) %>>% graph
      }

      private$.learner = GraphLearner$new(graph, task_type = "regr", clone_graph = clone_graph)
      if (length(param_vals) > 0L) {
        private$.learner$param_set$values = insert_named(private$.learner$param_set$values, param_vals)
      }

      pipeops = private$.learner$graph$pipeops
      if (length(fcst_iterative_pipeops(private$.learner$graph)) == 0L) {
        warning_input(
          "Graph contains no PipeOps with the 'fcst_iterative' property (e.g., PipeOpFcstLags). All horizon models use the same features."
        )
      }

      targetdiff_ids = names(keep(pipeops, inherits, "PipeOpTargetTrafoDifference"))
      if (length(targetdiff_ids) > 0L) {
        error_input(
          "PipeOpTargetTrafoDifference inside a DirectForecaster graph is not supported (found: %s): each horizon is inverted independently against the training tail, which is wrong for horizons >= 2. Wrap the forecaster with ppl(\"targettrafo\") instead.",
          str_collapse(targetdiff_ids, quote = "'")
        )
      }

      default_id = if (inherits(learner, "Learner")) learner$id else private$.learner$id
      super$initialize(
        id = id %??% paste0(default_id, ".direct"),
        task_type = "fcst",
        predict_types = private$.learner$predict_types,
        feature_types = private$.learner$feature_types,
        # one model per horizon: validation and internal tuning have no single delegate, and the
        # importance(), selected_features(), and oob_error() methods return one result per horizon
        # instead of the single value the mlr3 property contract promises (AutoTuner and friends call
        # these expecting that shape). Hotstart is advertised by GraphLearner without being implemented.
        properties = setdiff(
          private$.learner$properties,
          c(
            "hotstart_backward",
            "hotstart_forward",
            "importance",
            "internal_tuning",
            "oob_error",
            "selected_features",
            "validation"
          )
        ),
        packages = c("mlr3forecast", private$.learner$packages),
        man = "mlr3forecast::DirectForecaster"
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
      cat_cli(cli::cli_li("Horizons: {self$horizons}"))
    },

    #' @description
    #' Not supported, use `$predict_newdata()` or [forecast()] instead.
    #' @param newdata (ignored).
    #' @param task (ignored).
    predict_newdata_fast = function(newdata, task = NULL) {
      error_input(
        "Learner '%s' does not support predict_newdata_fast(). Use predict_newdata() or forecast() instead.",
        self$id
      )
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
    #' The importance scores of the base learner of each horizon model, if it supports them.
    #' Unlike [mlr3::Learner]'s `$importance()` this returns one vector per horizon, so the
    #' `"importance"` property is deliberately not advertised.
    #' @return Named `list()` of named `numeric()`, one element per horizon (`h1`, `h2`, ...).
    importance = function() {
      assert_has_model(self)
      private$.per_horizon(function(glrn) glrn$importance())
    },

    #' @description
    #' The selected features of the base learner of each horizon model, if it supports them.
    #' @return Named `list()` of `character()`, one element per horizon (`h1`, `h2`, ...).
    selected_features = function() {
      assert_has_model(self)
      private$.per_horizon(function(glrn) glrn$selected_features())
    },

    #' @description
    #' The out-of-bag error of the base learner of each horizon model, if it supports it.
    #' @return Named `list()` of `numeric(1)`, one element per horizon (`h1`, `h2`, ...).
    oob_error = function() {
      assert_has_model(self)
      private$.per_horizon(function(glrn) glrn$oob_error())
    }
  ),

  active = list(
    #' @field learner ([mlr3::Learner])\cr
    #' The untrained base regression learner of the graph, the same as `$base_learner()`.
    learner = function(rhs) {
      assert_ro_binding(rhs)
      self$base_learner()
    },

    #' @field graph ([mlr3pipelines::Graph])\cr
    #' The wrapped graph, without the per-horizon shift.
    #' Read-only.
    graph = function(rhs) {
      assert_ro_binding(rhs)
      private$.learner$graph
    },

    #' @field quantiles (`numeric()`)\cr
    #' Numeric vector of probabilities to be used while predicting quantiles.
    #' Elements must be between 0 and 1, not missing and provided in ascending order.
    #' If only one quantile is provided, it is used as response.
    #' Otherwise, set `$quantile_response` to specify the response quantile.
    #' Set to `NULL` to reset both `$quantiles` and `$quantile_response`.
    quantiles = function(rhs) {
      if (missing(rhs)) {
        return(get_graph_quantile_field(private$.learner$graph, "quantiles", self$id))
      }
      set_graph_quantile_field(private$.learner$graph, "quantiles", rhs, self$id)
    },

    #' @field quantile_response (`numeric(1)`)\cr
    #' The quantile to be used as response.
    quantile_response = function(rhs) {
      if (missing(rhs)) {
        return(get_graph_quantile_field(private$.learner$graph, "quantile_response", self$id))
      }
      set_graph_quantile_field(private$.learner$graph, "quantile_response", rhs, self$id)
    },

    #' @field graph_model ([mlr3pipelines::Graph] | named `list()`)\cr
    #' [mlr3pipelines::Graph] that is being wrapped. After `$train()`, a named list with one trained
    #' [mlr3pipelines::Graph] per horizon (`h1`, `h2`, ...). Read-only.
    graph_model = function(rhs) {
      assert_ro_binding(rhs)
      if (is.null(self$model)) {
        return(private$.learner$graph)
      }
      private$.per_horizon(function(glrn) glrn$graph_model)
    },

    #' @field native_model (named `list()`)\cr
    #' The fitted models.
    native_model = function(rhs) {
      assert_ro_binding(rhs)
      if (is.null(self$model)) {
        return()
      }
      private$.per_horizon(function(glrn) glrn$base_learner()$native_model)
    },

    #' @field lags (`integer()` | `NULL`)\cr
    #' The lags of the first [PipeOpFcstLags] in the graph, which the model for horizon `h` shifts by `h - 1`,
    #' or `NULL` if there is none.
    lags = function(rhs) {
      assert_ro_binding(rhs)
      lag_po = detect(private$.learner$graph$pipeops, function(po) inherits(po, "PipeOpFcstLags"))
      if (is.null(lag_po)) {
        return()
      }
      lag_po$param_set$values$lags
    },

    #' @field horizons (`integer()`)\cr
    #' The forecast horizons.
    horizons = function(rhs) {
      assert_ro_binding(rhs)
      private$.horizons
    },

    #' @template field_param_set
    param_set = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.learner$param_set)) {
        error_input("param_set is read-only.")
      }
      private$.learner$param_set
    },

    #' @field hash (`character(1)`)\cr
    #' Hash (unique identifier) for this object.
    hash = function(rhs) {
      assert_ro_binding(rhs)
      calculate_hash(super$hash, private$.learner$phash, private$.horizons)
    },

    #' @field phash (`character(1)`)\cr
    #' Hash (unique identifier) for this partial object, excluding some components which are
    #' varied systematically during tuning (parameter values).
    phash = function(rhs) {
      assert_ro_binding(rhs)
      calculate_hash(super$phash, private$.learner$phash, private$.horizons)
    },

    #' @field marshaled (`logical(1)`)\cr
    #' Whether the learner's model is currently in marshaled form.
    marshaled = function() {
      learner_marshaled(self)
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
    .horizons = NULL,

    deep_clone = function(name, value) {
      if (name == ".learner") value$clone(deep = TRUE) else super$deep_clone(name, value)
    },

    .train = function(task) {
      graph = private$.learner$graph

      # the graph for horizon h shifts the iterative features by h - 1 steps, so they only use values observed at the
      # forecast origin, and its iterative PipeOps keep the shifted settings in their state
      graph_states = map(private$.horizons, function(h) {
        g = graph$clone(deep = TRUE)
        walk(fcst_iterative_pipeops(g), function(po) po$shift(h - 1L))
        g$train(task)
        set_class(g$state, c("graph_learner_model", class(g$state)))
      })

      # per-key origin and step let predict recover each row's step-distance
      order_cols = task$col_roles$order
      key_cols = task$col_roles$key
      dt = task$data(cols = c(order_cols, key_cols))
      step = task$freq
      origin = if (length(key_cols) > 0L) {
        dt[,
          list(..origin = max(order_cols), ..anchor = grid_anchor(order_cols, step)),
          by = key_cols,
          env = list(order_cols = order_cols, step = I(step), key_cols = I(key_cols))
        ]
      } else {
        max(dt[[order_cols]])
      }
      anchor = if (length(key_cols) > 0L) NA_integer_ else grid_anchor(dt[[order_cols]], step)

      # the lookback before shifting is the history every horizon's features reach back from the forecast origin
      cols = unique(c(task$target_names, task$feature_names, key_cols, order_cols))
      tail_dt = task$data(cols = cols)
      setorderv(tail_dt, c(key_cols, order_cols))
      lookback = max(0, map_dbl(fcst_iterative_pipeops(graph), function(po) po$lookback))
      # data.table's grouped tail() does not support n = 0
      train_tail = if (is.infinite(lookback)) {
        tail_dt
      } else if (lookback == 0) {
        tail_dt[0L]
      } else if (length(key_cols) > 0L) {
        tail_dt[, tail(.SD, lookback), by = key_cols, env = list(lookback = lookback, key_cols = I(key_cols))]
      } else {
        tail(tail_dt, lookback)
      }

      set_class(
        list(
          graph_states = graph_states,
          origin = origin,
          anchor = anchor,
          freq = step,
          train_tail = train_tail,
          target = task$target_names,
          feature_names = task$feature_names
        ),
        c("direct_forecaster_model", "list")
      )
    },

    .predict = function(task) {
      horizons = private$.horizons
      max_h = max(horizons)
      step = self$model$freq
      origin = self$model$origin
      order_cols = task$col_roles$order
      key_cols = task$col_roles$key

      ord = task$data(cols = c(key_cols, order_cols))

      # a row's step is its position on the future grid seq_order(origin, step, max_h)
      if (length(key_cols) > 0L) {
        ord = origin[ord, on = key_cols]
        unseen = unique(ord[is.na(ord$..origin), key_cols, with = FALSE])
        if (nrow(unseen) > 0L) {
          error_input(
            "No training rows for key group(s) %s, so the forecast origin is unknown.",
            str_collapse(key_labels(unseen, key_cols), quote = "'")
          )
        }
        ord[,
          "..step" := match(order_cols, seq_order(get("..origin")[1L], step, max_h, get("..anchor")[1L])),
          by = key_cols,
          env = list(order_cols = order_cols, step = I(step), max_h = max_h, key_cols = I(key_cols))
        ]
      } else {
        grid = seq_order(origin, step, max_h, self$model$anchor)
        set(ord, j = "..step", value = match(ord[[order_cols]], grid))
      }

      steps = ord$..step
      if (anyNA(steps)) {
        error_input("%i test row(s) are beyond the trained horizon (max %i steps).", sum(is.na(steps)), max_h)
      }
      ii = match(steps, horizons)
      if (anyNA(ii)) {
        bad = sort(unique(steps[is.na(ii)]))
        error_input(
          "Test set requires step(s) %s which were not trained (horizons: %s).",
          str_collapse(bad),
          str_collapse(horizons)
        )
      }

      target = self$model$target
      feature_names = self$model$feature_names
      test_cols = unique(c(target, intersect(feature_names, task$feature_names), key_cols, order_cols))
      test_data = task$data(cols = test_cols)

      # rebuild the backend as training tail + future-grid skeleton with test rows overlaid, so
      # lags resolve from training history and positional shifts equal true step distance
      if (length(key_cols) > 0L) {
        skeleton = ord[,
          set_names(list(seq_order(get("..origin")[1L], step, max(get("..step")), get("..anchor")[1L])), order_cols),
          by = key_cols,
          env = list(step = I(step), order_cols = I(order_cols), key_cols = I(key_cols))
        ]
      } else {
        skeleton = setnames(data.table(grid[seq_len(max(steps))]), order_cols)
      }
      future = test_data[skeleton, on = c(key_cols, order_cols)]
      combined = rbindlist(list(self$model$train_tail, future), use.names = TRUE, fill = TRUE)
      set(combined, j = "..row_id", value = seq_row(combined))

      backend = DataBackendDataTable$new(combined, "..row_id")
      step_task = as_task_fcst(backend, target = target, order = order_cols, key = key_cols, freq = self$model$freq)
      step_task$col_roles$feature = intersect(feature_names, names(combined))

      lookup = combined[, c(key_cols, order_cols, "..row_id"), with = FALSE]
      active = task$data(cols = c(key_cols, order_cols))
      cids = lookup[active, on = c(key_cols, order_cols), "..row_id"][[1L]]

      out = private$.predict_horizons(step_task, cids, ii)

      out_data = task$data(cols = c(target, key_cols, order_cols))
      new_data = list(
        row_ids = task$row_ids,
        truth = out_data[[target]],
        extra = as.list(out_data[, c(key_cols, order_cols), with = FALSE]),
        col_roles = list(order = order_cols, key = key_cols)
      )
      # returning a Prediction bypasses the weights injection of as_prediction_data.list
      if ("weights_measure" %chin% task$properties) {
        new_data$weights = task$weights_measure[list(row_id = task$row_ids), on = "row_id", "weight"][[1L]]
      }
      out$data = insert_named(out$data, new_data)
      out
    },

    .base_learner = function(recursive = Inf) {
      # transparent like RecursiveForecaster, so base_learner(1) is the learner of the graph for both forecasters
      if (recursive <= 0) self else private$.learner$base_learner(recursive)
    },

    # a GraphLearner holding the shifted graph and trained state of the i-th horizon
    .horizon_learner = function(i) {
      glrn = private$.learner$clone(deep = TRUE)
      walk(fcst_iterative_pipeops(glrn$graph), function(po) po$shift(private$.horizons[[i]] - 1L))
      glrn$model = self$model$graph_states[[i]]
      glrn
    },

    .per_horizon = function(fn) {
      assert_unmarshaled(self)
      out = map(seq_along(private$.horizons), function(i) fn(private$.horizon_learner(i)))
      set_names(out, paste0("h", private$.horizons))
    },

    .predict_horizons = function(task, row_ids, ii) {
      task = task$clone()
      # the live graph carries the current predict hyperparameters, and each horizon's state its trained models
      graph = private$.learner$graph
      on.exit({
        graph$state = NULL
      })
      graph_states = self$model$graph_states
      # one batched predict() per horizon instead of row-by-row
      preds = imap(split(row_ids, ii), function(ids, i) {
        task$row_roles$use = ids
        graph$state = graph_states[[as.integer(i)]]
        as_prediction_fcst(graph$predict(task)[[1L]])
      })
      # batches come back in model order; restore the caller's row_ids order
      reorder_prediction(do.call(c, preds), row_ids)
    }
  )
)

#' @export
#' @method print direct_forecaster_model
print.direct_forecaster_model = function(x, ...) {
  cat_cli({
    cli::cli_text("<direct_forecaster_model>")
    cli::cli_li("Target: {x$target}")
    cli::cli_li("Frequency: {x$freq}")
    cli::cli_li("Horizon models: {length(x$graph_states)}")
  })
  invisible(x)
}

#' @export
#' @method marshal_model direct_forecaster_model
marshal_model.direct_forecaster_model = function(model, inplace = FALSE, ...) {
  graph_states = map(model$graph_states, marshal_model, inplace = inplace, ...)
  if (!some(graph_states, is_marshaled_model)) {
    return(model)
  }
  set_class(
    list(
      marshaled = insert_named(model, list(graph_states = graph_states)),
      packages = c("mlr3pipelines", "mlr3forecast")
    ),
    c(paste0(class(model), "_marshaled"), "marshaled")
  )
}

#' @export
#' @method unmarshal_model direct_forecaster_model_marshaled
unmarshal_model.direct_forecaster_model_marshaled = function(model, inplace = FALSE, ...) {
  m = model$marshaled
  m$graph_states = map(m$graph_states, unmarshal_model, inplace = inplace, ...)
  set_class(m, c("direct_forecaster_model", "list"))
}

#' @export
#' @method default_fallback DirectForecaster
default_fallback.DirectForecaster = function(learner, ...) {
  default_fallback(learner$learner, ...)
}
