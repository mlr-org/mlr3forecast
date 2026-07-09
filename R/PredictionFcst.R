#' @title Prediction Object for Forecasting
#'
#' @description
#' This object wraps the predictions returned by a forecast learner ([LearnerFcst], [RecursiveForecaster],
#' [DirectForecaster]). It subclasses [mlr3::PredictionRegr], so forecasting is treated as regression: the
#' `response`, `se`, `quantiles` and `distr` fields and all regression measures continue to work.
#'
#' In addition, the prediction carries the time index (and any key columns) of the forecast horizon in its
#' `$data$extra` slot. These are exposed via the `$order` and `$key` fields, lead the `as.data.table()` output,
#' and are used by [autoplot.PredictionFcst()] to draw a forecast plot.
#'
#' The `task_type` is kept as `"regr"` so that regression measures remain compatible: forecasting is scored as
#' regression.
#'
#' @seealso
#' Package \CRANpkg{mlr3viz} for some generic visualizations.
#'
#' @export
#' @examplesIf requireNamespace("forecast", quietly = TRUE)
#' task = tsk("airpassengers")
#' learner = lrn("fcst.auto_arima")$train(task)
#' p = forecast(learner, task, h = 12)
#' p$predict_types
#' head(as.data.table(p))
PredictionFcst = R6Class(
  "PredictionFcst",
  inherit = PredictionRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param task ([TaskFcst])\cr
    #'   Task, used to extract defaults for `row_ids` and `truth`.
    #' @param row_ids (`integer()`)\cr
    #'   Row ids of the predicted observations, i.e. the row ids of the test set.
    #' @param truth (`numeric()`)\cr
    #'   True (observed) response.
    #' @param response (`numeric()`)\cr
    #'   Vector of numeric response values. One element for each observation in the test set.
    #' @param se (`numeric()`)\cr
    #'   Numeric vector of predicted standard errors. One element for each observation in the test set.
    #' @param quantiles (`matrix()`)\cr
    #'   Numeric matrix of predicted quantiles. One row per observation, one column per quantile.
    #' @param distr (`VectorDistribution`)\cr
    #'   `VectorDistribution` from package distr6 (in repository \url{https://raphaels1.r-universe.dev}).
    #' @param weights (`numeric()`)\cr
    #'   Vector of measure weights for each observation.
    #' @param check (`logical(1)`)\cr
    #'   If `TRUE`, performs some argument checks and predict type conversions.
    #' @param extra (`list()`)\cr
    #'   Named list carrying the order (time) column and any key columns of the forecast horizon. The list
    #'   names are the original task column names.
    #' @param raw (any)\cr
    #'   Raw prediction object from the upstream model. Stored as-is without validation.
    initialize = function(
      task = NULL,
      row_ids = task$row_ids,
      truth = task$truth(),
      response = NULL,
      se = NULL,
      quantiles = NULL,
      distr = NULL,
      weights = NULL,
      check = TRUE,
      extra = NULL,
      raw = NULL
    ) {
      pdata = set_class(
        compact(list(
          row_ids = row_ids,
          truth = truth,
          response = response,
          se = se,
          quantiles = quantiles,
          distr = distr,
          weights = weights,
          extra = extra,
          raw = raw
        )),
        c("PredictionDataFcst", "PredictionData")
      )

      if (check) {
        pdata = check_prediction_data(pdata)
      }
      self$task_type = "regr"
      self$man = "mlr3forecast::PredictionFcst"
      self$data = pdata
      predict_types = intersect(names(mlr_reflections$learner_predict_types[["regr"]]), names(pdata))
      # response is in saved in quantiles matrix
      if ("quantiles" %chin% predict_types) {
        predict_types = union(predict_types, "response")
      }
      self$predict_types = predict_types
      if (is.null(pdata$response)) private$.quantile_response = attr(quantiles, "response")
    }
  ),

  active = list(
    #' @field order ([data.table::data.table()] | `NULL`)\cr
    #' The forecast time index, recovered from `$data$extra`. A table with two columns:
    #'
    #' * `row_id` (`integer()`), and
    #' * `order` (`Date()` | `POSIXct()` | `integer()` | `numeric()`).
    #'
    #' Returns `NULL` if no extra data is stored.
    order = function(rhs) {
      assert_ro_binding(rhs)
      roles = fcst_extra_roles(self$data$extra)
      if (is.null(roles$order)) {
        return()
      }
      data.table(row_id = self$data$row_ids, order = self$data$extra[[roles$order]])
    },

    #' @field key ([data.table::data.table()] | `NULL`)\cr
    #' The series identity columns of the forecast horizon, recovered from `$data$extra`. A table with two
    #' or more columns:
    #'
    #' * `row_id` (`integer()`), and
    #' * key variable(s) (`factor()` | `ordered()`).
    #'
    #' If there is only one key column, it is named `key`. Returns `NULL` if there are no key columns.
    key = function(rhs) {
      assert_ro_binding(rhs)
      roles = fcst_extra_roles(self$data$extra)
      if (length(roles$key) == 0L) {
        return()
      }
      data = data.table(row_id = self$data$row_ids)
      if (length(roles$key) == 1L) {
        set(data, j = "key", value = self$data$extra[[roles$key]])
      } else {
        for (k in roles$key) {
          set(data, j = k, value = self$data$extra[[k]])
        }
      }
      data[]
    }
  )
)

#' @export
as.data.table.PredictionFcst = function(x, ...) {
  tab = NextMethod()
  roles = fcst_extra_roles(x$data$extra)
  lead = intersect(c(roles$key, roles$order), names(tab))
  setcolorder(tab, c(lead, setdiff(names(tab), lead)))
  tab[]
}

fcst_extra_roles = function(extra) {
  nms = names(extra)
  is_key = map_lgl(extra, is.factor)
  order = nms[!is_key]
  if (length(order) > 1L) {
    stopf("Malformed forecast prediction: expected one order column in `$data$extra`, found %i.", length(order))
  }
  list(order = if (length(order) == 1L) order else NULL, key = nms[is_key])
}
