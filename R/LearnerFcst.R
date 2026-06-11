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

    # Attach the training context predict needs to the model itself: only the model survives
    # encapsulation (callr/future), private fields mutated during .train do not.
    .set_context = function(model, task) {
      attr(model, "fcst_row_ids") = task$row_ids
      attr(model, "fcst_max_index") = max(task$data(cols = task$col_roles$order)[[1L]])
      model
    },

    .is_newdata = function(task) {
      order_vals = task$backend$data(rows = task$row_ids, cols = task$col_roles$order)[[1L]]
      if (length(order_vals) == 0L) {
        return(TRUE)
      }
      max_index = attr(self$model, "fcst_max_index")
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
      idx = match(task$row_ids, attr(self$model, "fcst_row_ids"))
      if (anyNA(idx)) {
        error_input("In-sample prediction is only supported for rows used during training.")
      }
      private$.fitted()[idx]
    },

    .fitted = function() {
      as.numeric(stats::fitted(self$model))
    }
  )
)
