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
