#' @title Encapsulate a Learner as a Forecast Learner
#'
#' @description
#' A [mlr3pipelines::GraphLearner] subclass for iterative one-step-ahead forecasting.
#' Training is fully delegated to the graph, while prediction iterates row by row,
#' updating PipeOps that implement the `update_history()` method (e.g., [PipeOpFcstLags])
#' so that lag features reflect predicted values.
#'
#' Can be constructed in two ways:
#' * **Simple**: `ForecastLearner$new(learner, lags = 1:3)` -- internally builds
#'   `po("fcst.lags", lags = lags) %>>% learner`.
#' * **Graph**: `ForecastLearner$new(graph)` -- takes an arbitrary
#'   [mlr3pipelines::Graph] or [mlr3pipelines::PipeOp].
#'
#' @export
ForecastLearner = R6::R6Class(
  "ForecastLearner",
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
        task_type = "regr",
        predict_type = predict_type,
        clone_graph = clone_graph
      )

      has_iterative = any(map_lgl(
        self$graph$pipeops,
        function(po) exists("update_history", envir = po, inherits = FALSE)
      ))
      if (!has_iterative) {
        warning_input(
          "Graph contains no PipeOps with iterative forecasting support (e.g., PipeOpFcstLags). Predictions will not use recursive forecasting."
        )
      }
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function() {
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
        return(NULL)
      }
      lag_po$param_set$get_values()$lags
    }
  ),

  private = list(
    .predict = function(task) {
      on.exit({
        self$graph$state = NULL
      })
      self$graph$state = self$model

      iterative_pos = keep(self$graph$pipeops, function(po) exists("update_history", envir = po, inherits = FALSE))

      if (length(iterative_pos) == 0L) {
        prediction = self$graph$predict(task)
        return(prediction[[1L]])
      }

      target = task$target_names
      order_cols = task$col_roles$order
      key_cols = task$col_roles$key

      ord = task$data(cols = c(key_cols, order_cols))
      ord[, "..row_id" := task$row_ids]
      setorderv(ord, c(key_cols, order_cols))
      row_ids = ord[["..row_id"]]
      n = length(row_ids)

      single_task = task$clone()
      preds = vector("list", n)
      for (i in seq_len(n)) {
        single_task$row_roles$use = row_ids[i]

        prediction = self$graph$predict(single_task)
        preds[[i]] = prediction[[1L]]

        new_row = task$data(rows = row_ids[i], cols = c(target, order_cols, key_cols))
        set(new_row, j = target, value = prediction[[1L]]$response)
        for (po in iterative_pos) {
          po$update_history(new_row)
        }
      }

      combined = do.call(c, preds)
      combined$data = insert_named(
        combined$data,
        list(row_ids = row_ids, extra = as.list(task$data(cols = c(key_cols, order_cols))))
      )
      combined
    },

    .find_lag_po = function() {
      lag_po_id = detect(
        names(self$graph$pipeops),
        function(id) inherits(self$graph$pipeops[[id]], "PipeOpFcstLags")
      )
      if (is.null(lag_po_id)) {
        return(NULL)
      }
      self$graph$pipeops[[lag_po_id]]
    }
  )
)

#' @title Convert to a Forecast Learner
#'
#' @description
#' Creates a [ForecastLearner] (recursive strategy) or [DirectForecaster] (direct strategy).
#' If `horizons` is provided, a [DirectForecaster] is created; otherwise a [ForecastLearner].
#'
#' @param learner ([mlr3::Learner] | [mlr3pipelines::Graph] | [mlr3pipelines::PipeOp])\cr
#'   A regression learner (when `lags` is provided) or a graph/PipeOp.
#' @param lags (`integer()` | `NULL`)\cr
#'   The lag values to use for creating lag features.
#' @param horizons (`integer(1)` | `integer()` | `NULL`)\cr
#'   If provided, creates a [DirectForecaster] with one model per horizon.
#'   A single integer `H` is expanded to `1:H`.
#' @param ... (any)\cr
#'   Additional arguments passed to [ForecastLearner] or [DirectForecaster].
#' @return [ForecastLearner] or [DirectForecaster].
#' @export
as_learner_fcst = function(learner, lags = NULL, horizons = NULL, ...) {
  if (!is.null(horizons)) {
    DirectForecaster$new(learner, lags = lags, horizons = horizons, ...)
  } else {
    ForecastLearner$new(learner, lags = lags, ...)
  }
}
