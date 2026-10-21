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
#' @examplesIf mlr3misc::require_namespaces("ggplot2", quietly = TRUE)
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
  if (length(key) > 0L) {
    set(data, j = "..key", value = fcst_plot_key(data, key))
  }

  mapping = if (length(key) > 0L && !facets) {
    list(ggplot2::aes(colour = .data[["..key"]]), ggplot2::labs(colour = str_collapse(key, sep = "/")))
  }
  facet = if (length(key) > 0L && facets) ggplot2::facet_wrap(ggplot2::vars(.data[["..key"]]), scales = "free_y")

  ggplot2::ggplot(data, ggplot2::aes(x = .data[[order]], y = .data[[target]])) +
    mapping +
    facet +
    ggplot2::geom_line(...) +
    theme
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
#' For quantile forecasts, symmetric quantile pairs (e.g. the 10% and 90% quantiles) are drawn as shaded
#' central prediction interval ribbons over the forecast region, shaded darker for narrower intervals and
#' labelled by their level (e.g. 80, 95) in a legend. Quantiles without a symmetric partner are not drawn.
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
#' @exportS3Method ggplot2::autoplot
#' @examplesIf mlr3misc::require_namespaces(c("forecast", "ggplot2"), quietly = TRUE)
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

  # take the columns from the prediction, since united local-model predictions carry their own key column
  order = object$col_roles$order
  key = object$col_roles$key
  if (length(order) == 0L) {
    error_input("Cannot determine the time index of the prediction.")
  }
  target = task$col_roles$target

  fc = as.data.table(object)
  data = fc[, c(order, key, "response"), with = FALSE]
  setnames(data, "response", "..value")
  parts = list(forecast = data)

  if (!is.null(task)) {
    key_cols = task$col_roles$key
    hist = task$data(cols = c(target, order, key_cols))
    setnames(hist, target, "..value")
    if (length(key_cols) > 0L && length(key) == 1L && !identical(key_cols, key)) {
      # rebuild the united prediction's key labels with the same labelling as fcst.splitkey
      keys = key_table(hist, key_cols)
      labels = keys[hist, on = key_cols, "..label"][[1L]]
      if (is.factor(fc[[key]])) {
        labels = factor(labels, levels = levels(fc[[key]]))
      }
      set(hist, j = key, value = labels)
      set(hist, j = setdiff(key_cols, key), value = NULL)
    }
    # bridge the last observation before each series' forecast into the forecast group for line continuity
    setorderv(hist, c(key, order))
    starts = data[, list(..start = min(.SD[[1L]])), by = c(key), .SDcols = order]
    start = if (length(key) > 0L) starts[hist, on = key, "..start"][[1L]] else starts[["..start"]]
    ii = which(hist[[order]] < start)
    bridge = hist[ii, .SD[.N], by = c(key)]
    parts = list(history = hist, forecast = rbindlist(list(bridge, data), fill = TRUE))
  }

  data = rbindlist(parts, fill = TRUE, idcol = "..type")
  set(data, j = "..type", value = fctr(data[["..type"]], levels = c("history", "forecast")))
  if (length(key) > 0L) {
    set(data, j = "..key", value = fcst_plot_key(data, key))
  }

  mapping = if (length(key) > 0L && !facets) {
    list(
      ggplot2::aes(colour = .data[["..key"]], linetype = .data[["..type"]]),
      ggplot2::labs(colour = str_collapse(key, sep = "/"), linetype = NULL),
      ggplot2::guides(colour = ggplot2::guide_legend(order = 1L), linetype = ggplot2::guide_legend(order = 2L))
    )
  } else {
    list(
      ggplot2::aes(colour = .data[["..type"]]),
      ggplot2::labs(colour = NULL),
      ggplot2::guides(colour = ggplot2::guide_legend(order = 1L))
    )
  }
  facet = if (length(key) > 0L && facets) ggplot2::facet_wrap(ggplot2::vars(.data[["..key"]]), scales = "free_y")

  ggplot2::ggplot(data, ggplot2::aes(x = .data[[order]], y = .data[["..value"]])) +
    mapping +
    facet +
    fcst_quantile_ribbon(object, fc, order, key) +
    ggplot2::geom_line(...) +
    ggplot2::ylab(target %??% "response") +
    theme
}

# draw symmetric quantile pairs (p, 1 - p) as central prediction interval ribbons
fcst_quantile_ribbon = function(object, fc, order, key) {
  .data = NULL
  quantiles = object$data$quantiles
  if (is.null(quantiles)) {
    return()
  }
  # parse the column names, since the `probs` attribute does not survive filtering
  probs = as.numeric(sub("^q", "", colnames(quantiles)))
  lower = which(probs < 0.5)
  upper = match(round(1 - probs[lower], 10L), round(probs, 10L))
  keep = !is.na(upper)
  if (!any(keep)) {
    return()
  }
  ribbon = pmap_dtr(list(lower[keep], upper[keep]), function(lower, upper) {
    out = fc[, c(order, key), with = FALSE]
    set(out, j = "..lower", value = quantiles[, lower])
    set(out, j = "..upper", value = quantiles[, upper])
    set(out, j = "..level", value = round(100 * (probs[upper] - probs[lower])))
    out
  })
  # draw wider intervals first so narrower ones shade on top
  setorderv(ribbon, "..level", order = -1L)
  if (length(key) > 0L) {
    set(ribbon, j = "..key", value = fcst_plot_key(ribbon, key))
  }
  ribbon[, "..group" := .GRP, by = c("..level", key)]

  list(
    ggplot2::geom_ribbon(
      data = ribbon,
      ggplot2::aes(
        x = .data[[order]],
        ymin = .data[["..lower"]],
        ymax = .data[["..upper"]],
        group = .data[["..group"]],
        fill = .data[["..level"]]
      ),
      alpha = 0.4,
      inherit.aes = FALSE
    ),
    ggplot2::scale_fill_gradientn(
      colours = c("grey55", "grey80"),
      breaks = sort(unique(ribbon[["..level"]])),
      # untitled guides sort by hash, which varies between sessions, so pin the order everywhere
      guide = ggplot2::guide_legend(order = 3L),
      name = "level"
    )
  )
}

fcst_plot_key = function(dt, key) {
  interaction(dt[, key, with = FALSE], sep = "/", drop = TRUE)
}

#' @export
plot.PredictionFcst = function(x, ...) {
  require_namespaces("ggplot2")
  print(ggplot2::autoplot(x, ...))
}
