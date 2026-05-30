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
#' # or use as_learner_fcst with strategy = "direct"
#' flrn = as_learner_fcst(
#'   lrn("regr.rpart"),
#'   lags = 1:3,
#'   strategy = "direct",
#'   horizons = length(split$test)
#' )
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
    #'   The base lag values.
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
      private$.lags = lags
      private$.horizons = horizons

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

      super$initialize(
        id = id %??% private$.learner$id,
        task_type = "fcst",
        predict_types = private$.learner$predict_types,
        feature_types = private$.learner$feature_types,
        properties = private$.learner$properties,
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

    #' @field lags (`integer()`)\cr
    #' The base lags.
    lags = function(rhs) {
      assert_ro_binding(rhs)
      private$.lags
    },

    #' @field horizons (`integer()`)\cr
    #' The forecast horizons.
    horizons = function(rhs) {
      assert_ro_binding(rhs)
      private$.horizons
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
    .lags = NULL,
    .horizons = NULL,

    .train = function(task) {
      lags = private$.lags
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
      freq = task$freq %??% infer_freq(dt[[order_cols]])
      origin = if (length(key_cols) > 0L) {
        dt[, list(.origin = max(get(order_cols))), by = key_cols]
      } else {
        max(dt[[order_cols]])
      }

      structure(
        list(models = models, origin = origin, freq = freq),
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
      set(ord, j = "..row_id", value = task$row_ids)

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
      idx = match(steps, horizons)
      if (anyNA(idx)) {
        bad = sort(unique(steps[is.na(idx)]))
        error_input(
          "Test set requires step(s) %s which were not trained (horizons: %s).",
          toString(bad),
          toString(horizons)
        )
      }

      combined = private$.predict_horizons(task, models, ord$..row_id, idx)

      combined$data = insert_named(
        combined$data,
        list(extra = as.list(task$data(rows = combined$data$row_ids, cols = c(key_cols, order_cols))))
      )
      combined
    },

    .predict_horizons = function(task, models, row_ids, horizon_idx) {
      single_task = task$clone()
      preds = vector("list", length(row_ids))
      for (i in seq_along(row_ids)) {
        single_task$row_roles$use = row_ids[i]
        preds[[i]] = models[[horizon_idx[i]]]$predict(single_task)
      }
      do.call(c, preds)
    }
  )
)

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
