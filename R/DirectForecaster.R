#' @title Direct Multi-Step Forecast Learner
#'
#' @description
#' Trains a separate model for each forecast horizon. For horizon `h` with base lags `1:p`,
#' model `h` uses lags `h:(h+p-1)`, so that at prediction time only observed values are needed.
#' Unlike [ForecastLearner], predictions do not feed back into subsequent steps (no error accumulation).
#'
#' Can be constructed in two ways:
#' * **Simple**: `DirectForecaster$new(learner, lags = 1:3, horizons = 3)` -- internally builds
#'   one graph per horizon with offset lags.
#' * **Graph**: `DirectForecaster$new(graph, lags = 1:3, horizons = 3)` -- the graph should NOT
#'   contain [PipeOpFcstLags]; offset lags are prepended automatically per horizon.
#'
#' @export
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
    #' @param horizons (`integer(1)` | `integer()`)\cr
    #'   Either a single integer `H` (expanded to `1:H`) or an integer vector of specific horizons.
    initialize = function(learner, lags, horizons) {
      lags = assert_integerish(lags, lower = 1L, any.missing = FALSE, coerce = TRUE)
      horizons = assert_integerish(horizons, lower = 1L, any.missing = FALSE, coerce = TRUE)
      if (length(horizons) == 1L) {
        horizons = seq_len(horizons)
      }
      private$.lags = lags
      private$.horizons = horizons

      if (inherits(learner, "Graph") || inherits(learner, "PipeOp")) {
        graph = as_graph(learner, clone = TRUE)
      } else {
        assert_learner(as_learner(learner), task_type = "regr")
        graph = as_graph(as_learner(learner, clone = TRUE))
      }

      private$.learner = GraphLearner$new(graph, task_type = "regr")
      super$initialize(
        id = private$.learner$id,
        task_type = "regr",
        predict_types = private$.learner$predict_types,
        feature_types = private$.learner$feature_types,
        properties = private$.learner$properties,
        packages = c("mlr3forecast", private$.learner$packages),
        man = private$.learner$man
      )
      private$.predict_type = private$.learner$predict_type
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function() {
      super$print()
      cat_cli(cli::cli_li("Lags: {self$lags}"))
      cat_cli(cli::cli_li("Horizons: {self$horizons}"))
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

    #' @field predict_type (`character(1)`)\cr
    #' Stores the currently active predict type.
    predict_type = function(rhs) {
      if (missing(rhs)) {
        return(private$.predict_type)
      }
      if (rhs %nin% self$predict_types) {
        stopf("Learner '%s' does not support predict type '%s'.", self$id, rhs)
      }
      private$.learner$predict_type = rhs
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

      models = set_names(
        map(horizons, function(h) {
          offset_lags = lags + (h - 1L)
          g = po("fcst.lags", lags = offset_lags) %>>% as_graph(graph, clone = TRUE)
          glrn = GraphLearner$new(g, task_type = "regr")
          glrn$train(task)
        }),
        horizons
      )

      structure(list(models = models), class = c("direct_forecaster_model", "list"))
    },

    .predict = function(task) {
      models = self$model$models
      horizons = private$.horizons
      H = length(horizons)
      order_cols = task$col_roles$order
      key_cols = task$col_roles$key

      ord = task$data(cols = c(key_cols, order_cols))
      ord[, "..row_id" := task$row_ids]
      setorderv(ord, c(key_cols, order_cols))

      if (length(key_cols) > 0L) {
        preds = map(split(ord, by = key_cols, drop = TRUE), function(group) {
          row_ids = group[["..row_id"]]
          horizon_idx = rep_len(seq_len(H), length(row_ids))
          private$.predict_horizons(task, models, row_ids, horizon_idx)
        })
        combined = do.call(c, preds)
      } else {
        row_ids = ord[["..row_id"]]
        horizon_idx = rep_len(seq_len(H), length(row_ids))
        combined = private$.predict_horizons(task, models, row_ids, horizon_idx)
      }

      combined$data = insert_named(
        combined$data,
        list(
          row_ids = task$row_ids,
          extra = as.list(task$data(cols = c(key_cols, order_cols)))
        )
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
