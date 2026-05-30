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
#' @export
#' @examples
#' task = tsk("airpassengers")
#' autoplot(task)
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
  print(autoplot(x, ...))
}
