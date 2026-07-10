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

  # recover the order (time index) and key column names from the prediction's extra slot; the
  # task's column names are not authoritative here since a prediction united from local
  # per-series models carries a reconstructed generic key column instead of the task keys
  roles = fcst_extra_roles(object$data$extra)
  if (is.null(roles$order)) {
    error_input("Cannot determine the time index of the prediction.")
  }
  order = roles$order
  key = roles$key

  ylab = if (!is.null(task)) task$col_roles$target else "response"

  # forecast region
  data = fc[, c(order, key, "response"), with = FALSE]
  setnames(data, "response", ".value")
  set(data, j = ".type", value = fctr("forecast", levels = c("history", "forecast")))

  ribbon = fcst_quantile_ribbon(object, fc, order, key)
  ribbon_layer = NULL
  if (!is.null(ribbon)) {
    # draw wider intervals first so narrower ones shade on top
    setorderv(ribbon, ".level", order = -1L)
    if (length(key) > 0L) {
      ribbon[, ".key" := interaction(.SD, sep = "/", drop = TRUE), .SDcols = key]
      group = paste(ribbon$.level, ribbon$.key)
    } else {
      group = ribbon$.level
    }
    set(ribbon, j = ".group", value = fctr(group))
    ribbon_layer = list(
      ggplot2::geom_ribbon(
        data = ribbon,
        ggplot2::aes(
          x = .data[[order]],
          ymin = .data[[".lower"]],
          ymax = .data[[".upper"]],
          group = .data[[".group"]],
          fill = .data[[".level"]]
        ),
        alpha = 0.4,
        inherit.aes = FALSE
      ),
      ggplot2::scale_fill_gradientn(
        colours = c("grey55", "grey80"),
        breaks = sort(unique(ribbon$.level)),
        # untitled guides sort by hash, which varies between sessions, so pin the order everywhere
        guide = ggplot2::guide_legend(order = 3L),
        name = "level"
      )
    )
  }

  if (!is.null(task)) {
    target = task$col_roles$target
    key_cols = task$col_roles$key
    hist = task$data(cols = c(target, order, key_cols))
    setnames(hist, target, ".value")
    if (length(key_cols) > 0L && length(key) == 1L && !identical(key_cols, key)) {
      # rebuild the united prediction's key labels from the task's key columns
      set(hist, j = key, value = factor(key_labels(hist, key_cols), levels = levels(fc[[key]])))
      set(hist, j = setdiff(key_cols, key), value = NULL)
    }
    set(hist, j = ".type", value = fctr("history", levels = c("history", "forecast")))
    # bridge the last historical observation per series into the forecast group for line continuity
    if (length(key) > 0L) {
      setorderv(hist, c(key, order))
      bridge = hist[, .SD[.N], by = key]
    } else {
      setorderv(hist, order)
      bridge = hist[.N]
    }
    bridge = copy(bridge)
    set(bridge, j = ".type", value = fctr("forecast", levels = c("history", "forecast")))
    data = rbindlist(list(hist, bridge, data), use.names = TRUE, fill = TRUE)
  }

  if (length(key) == 0L) {
    p = ggplot2::ggplot(
      data,
      ggplot2::aes(x = .data[[order]], y = .data[[".value"]], colour = .data[[".type"]])
    ) +
      ggplot2::labs(colour = NULL) +
      ggplot2::guides(colour = ggplot2::guide_legend(order = 1L))
  } else {
    data[, ".key" := interaction(.SD, sep = "/", drop = TRUE), .SDcols = key]
    if (facets) {
      p = ggplot2::ggplot(
        data,
        ggplot2::aes(x = .data[[order]], y = .data[[".value"]], colour = .data[[".type"]])
      ) +
        ggplot2::facet_wrap(ggplot2::vars(.data[[".key"]]), scales = "free_y") +
        ggplot2::labs(colour = NULL) +
        ggplot2::guides(colour = ggplot2::guide_legend(order = 1L))
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
        ggplot2::labs(colour = paste(key, collapse = "/"), linetype = NULL) +
        ggplot2::guides(
          colour = ggplot2::guide_legend(order = 1L),
          linetype = ggplot2::guide_legend(order = 2L)
        )
    }
  }
  p + ribbon_layer + ggplot2::geom_line(...) + ggplot2::ylab(ylab) + theme
}

# pair symmetric quantile columns (p, 1 - p) into central prediction intervals, long over levels
fcst_quantile_ribbon = function(object, fc, order, key) {
  quantiles = object$data$quantiles
  if (is.null(quantiles)) {
    return()
  }
  probs = as.numeric(sub("^q", "", colnames(quantiles)))
  ii = which(probs < 0.5)
  jj = map_int(probs[ii], function(p) {
    j = which(abs(probs - (1 - p)) < sqrt(.Machine$double.eps))
    if (length(j) == 1L) j else NA_integer_
  })
  keep = !is.na(jj)
  if (!any(keep)) {
    return()
  }
  map_dtr(which(keep), function(i) {
    out = fc[, c(order, key), with = FALSE]
    set(out, j = ".lower", value = quantiles[, ii[i]])
    set(out, j = ".upper", value = quantiles[, jj[i]])
    set(out, j = ".level", value = round(100 * (probs[jj[i]] - probs[ii[i]])))
    out
  })
}

#' @export
plot.PredictionFcst = function(x, ...) {
  require_namespaces("ggplot2")
  print(ggplot2::autoplot(x, ...))
}
