#' @title Direct Multi-Step Forecast Learner
#'
#' @description
#' Trains a separate model for each forecast horizon. For horizon `h` with base lags `1:p`,
#' model `h` uses lags `h:(h+p-1)`, so that at prediction time only observed values are needed.
#' Unlike [RecursiveForecaster], predictions do not feed back into subsequent steps (no error accumulation).
#'
#' Lag features are managed internally with horizon-shifted offsets via `lags` -- do not include any
#' iterative feature PipeOp (property `"fcst_iterative"`, e.g. [PipeOpFcstLags], [PipeOpFcstRolling])
#' in the learner or graph. Such ops cannot yet be horizon-offset and would leak future information
#' for horizons > 1, so they are rejected at construction.
#'
#' @export
#' @examples
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
#' # or use the direct_forecaster() helper
#' flrn = direct_forecaster(lrn("regr.rpart"), lags = 1:3, horizons = length(split$test))
#' flrn$train(task, split$train)
#' flrn$predict(task, split$test)
DirectForecaster = R6::R6Class(
  "DirectForecaster",
  inherit = Learner,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
    #'   A regression learner or a graph/PipeOp (without [PipeOpFcstLags]).
    #' @param lags (`integer()`)\cr
    #'   The base lag values. Exposed in `$param_set` as `lags`, so it can be tuned via
    #'   [mlr3tuning::AutoTuner].
    #' @param horizons (`integer()`)\cr
    #'   Either a single integer `H` (expanded to `1:H`) or an integer vector of specific horizons.
    #'   One model is trained per horizon. At predict time each test row is routed to the model
    #'   matching its step-distance from the end of training, so with specific horizons (e.g.
    #'   `c(2L, 4L, 6L)`) the test set may only contain rows at those exact steps ahead.
    #' @param id (`character(1)` | `NULL`)\cr
    #'   Identifier, default `NULL` (auto-generated from the learner id).
    #' @param param_vals (named `list()`)\cr
    #'   Hyperparameter values applied to every horizon model. Per-horizon hyperparameters are not
    #'   currently supported.
    #' @param predict_type (`character(1)` | `NULL`)\cr
    #'   The predict type, default `NULL`.
    initialize = function(learner, lags, horizons, id = NULL, param_vals = list(), predict_type = NULL) {
      lags = assert_integerish(lags, lower = 1L, any.missing = FALSE, coerce = TRUE)
      horizons = assert_integerish(horizons, lower = 1L, any.missing = FALSE, coerce = TRUE)
      if (length(horizons) == 1L) {
        horizons = seq_len(horizons)
      }
      private$.horizons = horizons

      private$.fcst_param_set = ps(
        lags = p_uty(
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 1L, any.missing = FALSE, min.len = 1L))
        )
      )
      private$.fcst_param_set$set_values(lags = lags)

      if (inherits(learner, c("Graph", "PipeOp"))) {
        graph = as_graph(learner)
      } else {
        assert_learner(as_learner(learner), task_type = "regr")
        graph = as_graph(as_learner(learner))
      }

      private$.learner = GraphLearner$new(graph, task_type = "regr")
      if (length(param_vals)) {
        private$.learner$param_set$values = insert_named(private$.learner$param_set$values, param_vals)
      }

      iterative_ids = keep(
        names(private$.learner$graph$pipeops),
        function(id) "fcst_iterative" %in% private$.learner$graph$pipeops[[id]]$properties
      )
      if (length(iterative_ids) > 0L) {
        error_input(
          "Iterative feature PipeOps (property 'fcst_iterative') are not supported in a DirectForecaster graph (found: %s). Lags are handled internally via `lags`.",
          toString(iterative_ids)
        )
      }

      targetdiff_ids = keep(
        names(private$.learner$graph$pipeops),
        function(id) inherits(private$.learner$graph$pipeops[[id]], "PipeOpTargetTrafoDifference")
      )
      if (length(targetdiff_ids) > 0L) {
        error_input(
          "PipeOpTargetTrafoDifference inside a DirectForecaster graph is not supported (found: %s): each horizon is inverted independently against the training tail, which is wrong for horizons >= 2. Wrap the forecaster with ppl(\"targettrafo\") instead.",
          toString(targetdiff_ids)
        )
      }

      super$initialize(
        id = id %??% private$.learner$id,
        task_type = "fcst",
        predict_types = private$.learner$predict_types,
        feature_types = private$.learner$feature_types,
        properties = private$.learner$properties,
        packages = c("mlr3forecast", private$.learner$packages),
        man = private$.learner$man
      )
      private$.param_set = ParamSetCollection$new(list(
        private$.fcst_param_set,
        private$.learner$param_set
      ))
      private$.predict_type = private$.learner$predict_type
      if (!is.null(predict_type)) self$predict_type = predict_type
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function(...) {
      super$print()
      cat_cli(cli::cli_li("Lags: {self$lags}"))
      cat_cli(cli::cli_li("Horizons: {self$horizons}"))
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
    }
  ),

  active = list(
    #' @field learner ([mlr3::Learner])\cr
    #' The base regression learner.
    learner = function(rhs) {
      assert_ro_binding(rhs)
      private$.learner$base_learner()
    },

    #' @field native_model (named `list()`)\cr
    #' The fitted models of the base learner, one per forecast horizon and named `h<horizon>`. Returns `NULL` if
    #' the learner has not been trained.
    native_model = function(rhs) {
      assert_ro_binding(rhs)
      if (is.null(self$model)) {
        return()
      }
      models = map(self$model$models, function(glrn) glrn$base_learner()$model)
      set_names(models, paste0("h", self$horizons))
    },

    #' @field lags (`integer()`)\cr
    #' The base lags.
    lags = function(rhs) {
      assert_ro_binding(rhs)
      private$.fcst_param_set$values$lags
    },

    #' @field horizons (`integer()`)\cr
    #' The forecast horizons.
    horizons = function(rhs) {
      assert_ro_binding(rhs)
      private$.horizons
    },

    #' @template field_param_set
    param_set = function(rhs) {
      if (is.null(private$.param_set)) {
        private$.param_set = ParamSetCollection$new(list(
          private$.fcst_param_set,
          private$.learner$param_set
        ))
      }
      if (!missing(rhs) && !identical(rhs, private$.param_set)) {
        error_input("param_set is read-only.")
      }
      private$.param_set
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
      if (!is.null(self$model)) {
        walk(self$model$models, function(m) m$predict_type = rhs)
      }
      private$.predict_type = rhs
    }
  ),

  private = list(
    .learner = NULL,
    .fcst_param_set = NULL,
    .horizons = NULL,

    deep_clone = function(name, value) {
      switch(
        name,
        .learner = value$clone(deep = TRUE),
        .fcst_param_set = value$clone(deep = TRUE),
        .param_set = NULL,
        super$deep_clone(name, value)
      )
    },

    .train = function(task) {
      lags = private$.fcst_param_set$values$lags
      horizons = private$.horizons
      graph = private$.learner$graph

      models = map(horizons, function(h) {
        offset_lags = lags + (h - 1L)
        g = po("fcst.lags", lags = offset_lags) %>>% as_graph(graph, clone = TRUE)
        glrn = GraphLearner$new(g, task_type = "regr", clone_graph = FALSE)
        glrn$train(task)
      })

      # Store per-key origin and freq so predict can recover each row's step-distance.
      order_cols = task$col_roles$order
      key_cols = task$col_roles$key
      dt = task$data(cols = c(order_cols, key_cols))
      freq = task$freq %??% infer_freq(sort(unique(dt[[order_cols]])))
      origin = if (length(key_cols) > 0L) {
        dt[, list(.origin = max(get(order_cols))), by = key_cols]
      } else {
        max(dt[[order_cols]])
      }

      # Store the last max(lags) training rows per key: model h uses offset lags h:(h+p-1),
      # so a row at step h only ever looks back into these rows. Predict rebuilds its backend
      # from this tail, making predict_newdata()/forecast() work without the training backend.
      cols = unique(c(task$target_names, task$feature_names, key_cols, order_cols))
      tail_dt = task$data(cols = cols)
      setorderv(tail_dt, c(key_cols, order_cols))
      max_lag = max(lags)
      train_tail = if (length(key_cols) > 0L) {
        tail_dt[, tail(.SD, max_lag), by = key_cols]
      } else {
        tail(tail_dt, max_lag)
      }

      structure(
        list(
          models = models,
          origin = origin,
          freq = freq,
          train_tail = train_tail,
          target = task$target_names,
          feature_names = task$feature_names
        ),
        class = c("direct_forecaster_model", "list")
      )
    },

    .predict = function(task) {
      models = self$model$models
      horizons = private$.horizons
      max_h = max(horizons)
      freq = self$model$freq
      origin = self$model$origin
      order_cols = task$col_roles$order
      key_cols = task$col_roles$key

      ord = task$data(cols = c(key_cols, order_cols))

      # A row's step is its position on the future grid `seq(origin, by = freq, ...)`.
      if (length(key_cols) > 0L) {
        ord = origin[ord, on = key_cols]
        ord[,
          ".step" := match(get(order_cols), seq(get(".origin")[1L], by = freq, length.out = max_h + 1L)[-1L]),
          by = key_cols
        ]
      } else {
        grid = seq(origin, by = freq, length.out = max_h + 1L)[-1L]
        set(ord, j = ".step", value = match(ord[[order_cols]], grid))
      }

      steps = ord$.step
      if (anyNA(steps)) {
        error_input("%i test row(s) are beyond the trained horizon (max %i steps).", sum(is.na(steps)), max_h)
      }
      ii = match(steps, horizons)
      if (anyNA(ii)) {
        bad = sort(unique(steps[is.na(ii)]))
        error_input(
          "Test set requires step(s) %s which were not trained (horizons: %s).",
          toString(bad),
          toString(horizons)
        )
      }

      target = self$model$target
      feature_names = self$model$feature_names
      test_cols = unique(c(target, intersect(feature_names, task$feature_names), key_cols, order_cols))
      test_data = task$data(cols = test_cols)

      # Rebuild the predict backend as training tail + full future-grid skeleton with the test
      # rows overlaid, so lag features come from training values even when the task's backend
      # lacks history (predict_newdata()/forecast()) and positional shifts equal true step
      # distance even for sparse test rows.
      if (length(key_cols) > 0L) {
        skeleton = ord[,
          set_names(list(seq(get(".origin")[1L], by = freq, length.out = max(get(".step")) + 1L)[-1L]), order_cols),
          by = key_cols
        ]
      } else {
        skeleton = set_names(data.table(grid[seq_len(max(steps))]), order_cols)
      }
      future = test_data[skeleton, on = c(key_cols, order_cols)]
      combined = rbindlist(list(self$model$train_tail, future), use.names = TRUE, fill = TRUE)
      set(combined, j = "..row_id", value = seq_row(combined))

      backend = DataBackendDataTable$new(combined, "..row_id")
      step_task = as_task_fcst(backend, target = target, order = order_cols, key = key_cols, freq = freq)
      step_task$col_roles$feature = intersect(feature_names, names(combined))

      lookup = combined[, c(key_cols, order_cols, "..row_id"), with = FALSE]
      cids = lookup[task$data(cols = c(key_cols, order_cols)), on = c(key_cols, order_cols)][["..row_id"]]

      out = private$.predict_horizons(step_task, models, cids, ii)

      out_data = task$data(cols = c(target, key_cols, order_cols))
      out$data = insert_named(
        out$data,
        list(
          row_ids = task$row_ids,
          truth = out_data[[target]],
          extra = as.list(out_data[, c(key_cols, order_cols), with = FALSE])
        )
      )
      out
    },

    .predict_horizons = function(task, models, row_ids, horizon_idx) {
      task = task$clone()
      # One predict() per horizon model: all rows routed to the same model are predicted in a
      # single batch instead of row-by-row.
      preds = map(unique(horizon_idx), function(h) {
        task$row_roles$use = row_ids[horizon_idx == h]
        models[[h]]$predict(task)
      })
      combined = do.call(c, preds)
      # The batches above are concatenated in model order, so restore the input `row_ids` order
      # to keep the prediction aligned with the caller's row layout. Mutate in place to preserve
      # the PredictionData class on `$data`.
      data = combined$data
      ord = match(row_ids, data$row_ids)
      for (nm in names(data)) {
        x = data[[nm]]
        data[[nm]] = if (is.matrix(x)) {
          x[ord, , drop = FALSE]
        } else if (length(x) == length(ord)) {
          x[ord]
        } else {
          x
        }
      }
      combined$data = data
      combined
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
    cli::cli_li("Horizon models: {length(x$models)}")
  })
  invisible(x)
}

#' @export
#' @method marshal_model direct_forecaster_model
marshal_model.direct_forecaster_model = function(model, inplace = FALSE, ...) {
  if (inplace) {
    model$models = map(model$models, function(m) {
      m$model = marshal_model(m$model, inplace = TRUE, ...)
      m
    })
    return(structure(
      list(marshaled = model, packages = c("mlr3pipelines", "mlr3forecast")),
      class = c(paste0(class(model), "_marshaled"), "marshaled")
    ))
  }
  # inplace = FALSE: clone each learner without its model so the deep clone is cheap,
  # then attach the marshaled model to the clone. Restore the original on exit.
  marshaled_models = map(model$models, function(m) {
    learner_model = m$model
    on.exit(
      {
        m$model = learner_model
      },
      add = TRUE
    )
    m$model = NULL
    m_clone = m$clone(deep = TRUE)
    m_clone$model = marshal_model(learner_model, inplace = FALSE, ...)
    m_clone
  })
  model$models = marshaled_models
  structure(
    list(marshaled = model, packages = c("mlr3pipelines", "mlr3forecast")),
    class = c(paste0(class(model), "_marshaled"), "marshaled")
  )
}

#' @export
#' @method unmarshal_model direct_forecaster_model_marshaled
unmarshal_model.direct_forecaster_model_marshaled = function(model, inplace = FALSE, ...) {
  m_inner = model$marshaled
  if (inplace) {
    m_inner$models = map(m_inner$models, function(m) {
      m$model = unmarshal_model(m$model, inplace = TRUE, ...)
      m
    })
    return(structure(m_inner, class = c("direct_forecaster_model", "list")))
  }
  unmarshaled_models = map(m_inner$models, function(m) {
    prev_model = m$model
    on.exit(
      {
        m$model = prev_model
      },
      add = TRUE
    )
    m$model = NULL
    m_clone = m$clone(deep = TRUE)
    m_clone$model = unmarshal_model(prev_model, inplace = FALSE, ...)
    m_clone
  })
  m_inner$models = unmarshaled_models
  structure(m_inner, class = c("direct_forecaster_model", "list"))
}
