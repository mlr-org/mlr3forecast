#' @title Plot for Forecast Tasks
#'
#' @description
#' Generates plots for [TaskFcst].
#'
#' @param object ([TaskFcst]).
#' @template param_theme
#' @param facets (`logical(1)`)\cr
#'   For keyed tasks, draw one panel per series instead of one coloured line per series. Default `FALSE`.
#' @param ... (`any`)\cr
#'   Additional argument, passed down to the underlying `geom` or plot functions.
#' @return [ggplot2::ggplot()] object.
#'
#' @exportS3Method ggplot2::autoplot
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' task = tsk("airpassengers")
#' ggplot2::autoplot(task)
autoplot.TaskFcst = function(object, theme = ggplot2::theme_minimal(), facets = FALSE, ...) {
  assert_flag(facets)
  .data = NULL
  col_roles = object$col_roles
  order = col_roles$order
  target = col_roles$target
  key = col_roles$key
  data = object$data(cols = c(target, order, key))

  if (length(key) == 0L) {
    p = ggplot2::ggplot(data, ggplot2::aes(x = .data[[order]], y = .data[[target]]))
  } else {
    data[, ".key" := interaction(.SD, sep = "/", drop = TRUE), .SDcols = key]
    if (facets) {
      p = ggplot2::ggplot(data, ggplot2::aes(x = .data[[order]], y = .data[[target]])) +
        ggplot2::facet_wrap(ggplot2::vars(.data[[".key"]]), scales = "free_y")
    } else {
      p = ggplot2::ggplot(
        data,
        ggplot2::aes(x = .data[[order]], y = .data[[target]], colour = .data[[".key"]])
      ) +
        ggplot2::labs(colour = paste(key, collapse = "/"))
    }
  }
  p + ggplot2::geom_line(...) + theme
}

#' @export
plot.TaskFcst = function(x, ...) {
  require_namespaces("ggplot2")
  print(ggplot2::autoplot(x, ...))
}

#' @title Plot for Forecast Predictions
#'
#' @description
#' Generates a forecast plot for [PredictionFcst]. The point forecast is drawn over the time index. When a
#' `task` is supplied, the historical series is overlaid and the forecast region is drawn in a distinct colour,
#' connected to the last historical observation for visual continuity.
#'
#' Prediction intervals from quantile forecasts are not drawn yet; this is planned for a future release.
#'
#' @param object ([PredictionFcst]).
#' @param task ([TaskFcst] | `NULL`)\cr
#'   Optional task providing the historical series to overlay. When `NULL`, only the forecast region is drawn.
#' @template param_theme
#' @param facets (`logical(1)`)\cr
#'   For keyed tasks, draw one panel per series instead of one coloured line per series. Default `FALSE`.
#' @param ... (`any`)\cr
#'   Additional argument, passed down to the underlying `geom` or plot functions.
#' @return [ggplot2::ggplot()] object.
#'
#' @examplesIf requireNamespace("forecast", quietly = TRUE) && requireNamespace("ggplot2", quietly = TRUE)
#' task = tsk("airpassengers")
#' learner = lrn("fcst.auto_arima")$train(task)
#' p = forecast(learner, task, h = 12)
#' ggplot2::autoplot(p, task = task)
autoplot.PredictionFcst = function(object, task = NULL, theme = ggplot2::theme_minimal(), facets = FALSE, ...) {
  assert_flag(facets)
  if (!is.null(task)) {
    task = assert_task(as_task_fcst(task), task_type = "fcst")
  }
  .data = NULL

  fc = as.data.table(object)

  # recover the order (time index) and key column names
  if (!is.null(task)) {
    order = task$col_roles$order
    key = task$col_roles$key
  } else {
    roles = fcst_extra_roles(object$data$extra)
    if (is.null(roles$order)) {
      error_input("Cannot determine the time index of the prediction; supply `task`.")
    }
    order = roles$order
    key = roles$key
  }

  ylab = if (!is.null(task)) task$col_roles$target else "response"

  # forecast region
  data = fc[, c(order, key, "response"), with = FALSE]
  setnames(data, "response", ".value")
  set(data, j = ".type", value = factor("forecast", levels = c("history", "forecast")))

  if (!is.null(task)) {
    target = task$col_roles$target
    hist = task$data(cols = c(target, order, key))
    setnames(hist, target, ".value")
    set(hist, j = ".type", value = factor("history", levels = c("history", "forecast")))
    # bridge the last historical observation per series into the forecast group for line continuity
    if (length(key) > 0L) {
      setorderv(hist, c(key, order))
      bridge = hist[, .SD[.N], by = key]
    } else {
      setorderv(hist, order)
      bridge = hist[.N]
    }
    bridge = copy(bridge)
    set(bridge, j = ".type", value = factor("forecast", levels = c("history", "forecast")))
    data = rbindlist(list(hist, bridge, data), use.names = TRUE, fill = TRUE)
  }

  if (length(key) == 0L) {
    p = ggplot2::ggplot(
      data,
      ggplot2::aes(x = .data[[order]], y = .data[[".value"]], colour = .data[[".type"]])
    ) +
      ggplot2::labs(colour = NULL)
  } else {
    data[, ".key" := interaction(.SD, sep = "/", drop = TRUE), .SDcols = key]
    if (facets) {
      p = ggplot2::ggplot(
        data,
        ggplot2::aes(x = .data[[order]], y = .data[[".value"]], colour = .data[[".type"]])
      ) +
        ggplot2::facet_wrap(ggplot2::vars(.data[[".key"]]), scales = "free_y") +
        ggplot2::labs(colour = NULL)
    } else {
      p = ggplot2::ggplot(
        data,
        ggplot2::aes(
          x = .data[[order]],
          y = .data[[".value"]],
          colour = .data[[".key"]],
          linetype = .data[[".type"]]
        )
      ) +
        ggplot2::labs(colour = paste(key, collapse = "/"), linetype = NULL)
    }
  }
  p + ggplot2::geom_line(...) + ggplot2::ylab(ylab) + theme
}

#' @export
plot.PredictionFcst = function(x, ...) {
  require_namespaces("ggplot2")
  print(ggplot2::autoplot(x, ...))
}
