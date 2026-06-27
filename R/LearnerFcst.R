#' @title Forecast Learner
#'
#' @description
#' This Learner specializes [mlr3::LearnerRegr] for forecast problems:
#'
#' * `task_type` is set to `"fcst"`.
#' * Creates [mlr3::Prediction]s of class [mlr3::PredictionRegr].
#' * Possible values for `predict_types` are:
#'   - `"response"`: Predicts a numeric response for each observation in the test set.
#'   - `"se"`: Predicts the standard error for each value of response for each observation in the test set.
#'   - `"distr"`: Probability distribution as `VectorDistribution` object (requires package `distr6`, available via
#'     repository \url{https://raphaels1.r-universe.dev}).
#'   - `"quantiles"`: Predicts quantile estimates for each observation in the test set.
#'     Set `$quantiles` to specify the quantiles to predict and `$quantile_response` to specify the response quantile.
#'     See the [mlr3book](https://mlr3book.mlr-org.com/chapters/chapter13/beyond_regression_and_classification.html)
#'     on quantile regression for more details.
#'
#' Predefined learners can be found in the [dictionary][mlr3misc::Dictionary] [mlr3::mlr_learners].
#'
#' @template param_id
#' @template param_param_set
#' @template param_predict_types
#' @template param_feature_types
#' @template param_learner_properties
#' @template param_packages
#' @template param_label
#' @template param_man
#'
#' @template seealso_learner
#' @export
#' @examples
#' # get all forecast learners from mlr_learners:
#' lrns = mlr_learners$mget(mlr_learners$keys("^fcst"))
#' names(lrns)
#'
#' # get a specific learner from mlr_learners:
#' mlr_learners$get("fcst.ets")
#' lrn("fcst.auto_arima")
LearnerFcst = R6Class(
  "LearnerFcst",
  inherit = LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      id,
      param_set = ps(),
      predict_types = "response",
      feature_types = character(),
      properties = character(),
      packages = character(),
      label = NA_character_,
      man = NA_character_
    ) {
      super$initialize(
        id = id,
        task_type = "fcst",
        param_set = param_set,
        feature_types = feature_types,
        predict_types = predict_types,
        properties = properties,
        packages = packages,
        label = label,
        man = man
      )
    }
  ),
  active = list(
    #' @field native_model (any)\cr
    #' The native model object from the upstream forecasting package. The learner's `$model` wraps it
    #' in a named list together with the training context needed at predict time.
    native_model = function(rhs) {
      assert_ro_binding(rhs)
      self$model$model
    }
  ),

  private = list(
    .train = function(task) {
      properties = task$properties
      if ("ordered" %nin% properties) {
        error_input("%s learner requires an ordered task.", self$id)
      }
      if ("keys" %in% properties) {
        error_input("%s learner does not support tasks with keys.", self$id)
      }
      invisible(NULL)
    },

    # tidy printed output with real series name and fn.
    .tidy_model = function(model, task) {
      if (!is.null(model$series)) {
        model$series = task$target_names
      }
      if (!is.null(model$call)) {
        if (!is.null(model$call[[private$.y_arg]])) {
          model$call[[private$.y_arg]] = as.name(task$target_names)
        }
        model$call[[1L]] = as.name(private$.fn)
      }
      model
    },

    .set_context = function(model, task) {
      list(
        model = model,
        row_ids = task$row_ids,
        max_index = max(task$data(cols = task$col_roles$order)[[1L]])
      )
    },

    .is_newdata = function(task) {
      order_vals = task$backend$data(rows = task$row_ids, cols = task$col_roles$order)[[1L]]
      if (length(order_vals) == 0L) {
        return(TRUE)
      }
      max_index = self$model$max_index
      if (all(order_vals > max_index)) {
        TRUE
      } else if (all(order_vals <= max_index)) {
        FALSE
      } else {
        error_input(
          "Cannot mix in-sample and future rows in one predict() call (last training index: %s).",
          format(max_index)
        )
      }
    },

    .fitted_response = function(task) {
      ii = match(task$row_ids, self$model$row_ids)
      if (anyNA(ii)) {
        error_input("In-sample prediction is only supported for rows used during training.")
      }
      private$.fitted()[ii]
    },

    .fitted = function() {
      as.numeric(stats::fitted(self$native_model))
    },

    # Quantile p as one side of the central interval (level 100 * |1 - 2p|): lower if p < 0.5,
    # upper if p > 0.5, mean at 0.5. `pred$lower`/`$upper` columns must be in ascending-level order.
    .quantiles_from_intervals = function(pred) {
      probs = private$.quantiles
      levels = sort(unique(quantiles_to_levels(probs)))
      quantiles = map_bc(probs, function(p) {
        if (p == 0.5) {
          return(as.numeric(pred$mean))
        }
        bounds = as.matrix(if (p < 0.5) pred$lower else pred$upper)
        as.numeric(bounds[, match(quantiles_to_levels(p), levels)])
      })
      setattr(quantiles, "probs", probs)
      setattr(quantiles, "response", private$.quantile_response)
      quantiles
    }
  )
)
