#' @title Mean Absolute Scaled Error
#'
#' @name mlr_measures_fcst.mase
#'
#' @description
#' Measures the mean absolute error of the forecast scaled by the in-sample mean absolute error of the naive
#' (or seasonal naive) forecast. Values less than one indicate the forecast is better than the naive baseline.
#'
#' @details
#' \deqn{
#'   \mathrm{MASE} = \frac{1}{n} \sum_{i=1}^n
#'     \frac{\lvert y_i - \hat y_i \rvert}
#'     {\frac{1}{T-m} \sum_{t=m+1}^T \lvert z_t - z_{t-m} \rvert}
#' }{
#'   mean(|y - yhat|) / mean(|diff(z, lag = m)|)
#' }
#' where \eqn{z} is the training series, \eqn{m} is the seasonal period, and \eqn{T} is the length of the
#' training series.
#'
#' @references
#' `r format_bib("hyndman2006another")`
#'
#' @templateVar id fcst.mase
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureMASE = R6Class(
  "MeasureMASE",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(period = p_int(lower = 1L, tags = "required"))
      param_set$set_values(period = 1L)

      super$initialize(
        id = "fcst.mase",
        param_set = param_set,
        range = c(0, Inf),
        minimize = TRUE,
        predict_type = "response",
        packages = "mlr3forecast",
        properties = c("requires_task", "requires_train_set"),
        label = "Mean Absolute Scaled Error",
        man = "mlr3forecast::mlr_measures_fcst.mase"
      )
    }
  ),
  private = list(
    .score = function(prediction, task, train_set, ...) {
      if ("keys" %in% task$properties) {
        error_input("%s does not support grouped tasks yet.", self$id)
      }
      train = task$data(rows = train_set, cols = task$target_names)[[1L]]
      period = self$param_set$get_values()$period
      scale = mean(abs(diff(train, lag = period)), na.rm = TRUE)
      resid = prediction$truth - prediction$response
      mean(abs(resid / scale), na.rm = TRUE)
    }
  )
)

#' @title Root Mean Squared Scaled Error
#'
#' @name mlr_measures_fcst.rmsse
#'
#' @description
#' Measures the root mean squared error of the forecast scaled by the in-sample mean squared error of the naive
#' (or seasonal naive) forecast. Values less than one indicate the forecast is better than the naive baseline.
#'
#' @details
#' \deqn{
#'   \mathrm{RMSSE} = \sqrt{\frac{1}{n} \sum_{i=1}^n
#'     \frac{(y_i - \hat y_i)^2}
#'     {\frac{1}{T-m} \sum_{t=m+1}^T (z_t - z_{t-m})^2}}
#' }{
#'   sqrt(mean((y - yhat)^2) / mean(diff(z, lag = m)^2))
#' }
#' where \eqn{z} is the training series, \eqn{m} is the seasonal period, and \eqn{T} is the length of the
#' training series.
#'
#' @references
#' `r format_bib("hyndman2006another")`
#'
#' @templateVar id fcst.rmsse
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureRMSSE = R6Class(
  "MeasureRMSSE",
  inherit = MeasureRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(period = p_int(lower = 1L, tags = "required"))
      param_set$set_values(period = 1L)

      super$initialize(
        id = "fcst.rmsse",
        param_set = param_set,
        range = c(0, Inf),
        minimize = TRUE,
        predict_type = "response",
        packages = "mlr3forecast",
        properties = c("requires_task", "requires_train_set"),
        label = "Root Mean Squared Scaled Error",
        man = "mlr3forecast::mlr_measures_fcst.rmsse"
      )
    }
  ),
  private = list(
    .score = function(prediction, task, train_set, ...) {
      if ("keys" %in% task$properties) {
        error_input("%s does not support grouped tasks yet.", self$id)
      }
      train = task$data(rows = train_set, cols = task$target_names)[[1L]]
      period = self$param_set$get_values()$period
      scale = mean(diff(train, lag = period)^2, na.rm = TRUE)
      resid = prediction$truth - prediction$response
      sqrt(mean(resid^2 / scale, na.rm = TRUE))
    }
  )
)

#' @include zzz.R
register_measure("fcst.mase", MeasureMASE)
register_measure("fcst.rmsse", MeasureRMSSE)
