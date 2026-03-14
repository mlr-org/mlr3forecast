#' @title Plot for Forecast Tasks
#'
#' @description
#' Generates plots for [TaskFcst].
#'
#' @param object ([TaskFcst]).
#' @template param_theme
#' @param ... (`any`)\cr
#'   Additional argument, passed down to the underlying `geom` or plot functions.
#' @return [ggplot2::ggplot()] object.
#'
#' @export
#' @examples
#' task = tsk("airpassengers")
#' autoplot(task)
autoplot.TaskFcst = function(object, theme = ggplot2::theme_minimal(), ...) {
  .data = NULL
  col_roles = object$col_roles
  cols = c(col_roles$target, union(col_roles$order, col_roles$feature))
  ggplot2::ggplot(object$data(cols = cols), ggplot2::aes(x = .data[[col_roles$order]], y = .data[[col_roles$target]])) +
    ggplot2::geom_line() +
    theme
}

#' @export
plot.TaskFcst = function(x, ...) {
  print(autoplot(x, ...))
}

#' @title Plot for Forecast Predictions
#'
#' @description
#' Generates plots for [mlr3::PredictionRegr] objects from forecast learners.
#' Plots the true and predicted values as time series lines.
#' If the prediction contains quantiles, prediction intervals are shown as a ribbon.
#'
#' @param object ([mlr3::PredictionRegr]).
#' @param task ([TaskFcst])\cr
#'   The task used for training. If provided, the training data is shown as context.
#' @param train_ids (`integer()`)\cr
#'   Row IDs used for training. Required when `task` is provided to plot training data.
#' @template param_theme
#' @param ... (`any`)\cr
#'   Additional arguments, currently unused.
#' @return [ggplot2::ggplot()] object.
#'
#' @export
#' @examplesIf requireNamespace("forecast", quietly = TRUE)
#' task = tsk("airpassengers")
#' split = partition(task)
#' learner = lrn("fcst.auto_arima")
#' learner$train(task, split$train)
#' pred = learner$predict(task, split$test)
#' autoplot(pred)
#' autoplot(pred, task, split$train)
autoplot.PredictionRegr = function(object, task = NULL, train_ids = NULL, theme = ggplot2::theme_minimal(), ...) {
  if (is.null(object$data$extra)) {
    stop("Prediction does not contain time information. Use a forecast learner.")
  }

  order_col = names(object$data$extra)[1L]
  dt = data.table(
    order = object$data$extra[[1L]],
    truth = object$truth,
    response = object$response
  )

  p = ggplot2::ggplot(dt, ggplot2::aes(x = .data[["order"]]))

  if (!is.null(task) && !is.null(train_ids)) {
    col_roles = task$col_roles
    train_data = task$data(rows = train_ids, cols = c(col_roles$target, col_roles$order))
    setnames(train_data, c("truth", "order"))
    p = p + ggplot2::geom_line(data = train_data, ggplot2::aes(y = .data[["truth"]]), color = "black")
  }

  has_quantiles = !is.null(object$data$quantiles)
  if (has_quantiles) {
    probs = attr(object$data$quantiles, "probs")
    lower_col = 1L
    upper_col = length(probs)
    set(dt, j = "lower", value = object$data$quantiles[, lower_col])
    set(dt, j = "upper", value = object$data$quantiles[, upper_col])
    p = p +
      ggplot2::geom_ribbon(
        data = dt,
        ggplot2::aes(ymin = .data[["lower"]], ymax = .data[["upper"]]),
        alpha = 0.2,
        fill = "blue"
      )
  }

  p +
    ggplot2::geom_line(data = dt, ggplot2::aes(y = .data[["truth"]]), color = "black") +
    ggplot2::geom_line(data = dt, ggplot2::aes(y = .data[["response"]]), color = "blue") +
    ggplot2::labs(x = order_col, y = "value") +
    theme
}
