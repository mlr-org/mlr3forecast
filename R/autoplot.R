#' @title Plot for Forecast Tasks
#'
#' @description
#' Generates plots for [TaskFcst].
#'
#' @param object ([TaskFcst]).
#' @template param_theme
#' @param ... (`any`):
#'   Additional argument, passed down to the underlying `geom` or plot functions.
#' @return [ggplot2::ggplot()] object.
#'
#' @export
#' @examples
#' task = tsk("airpassengers")
#' autoplot(task)
autoplot.TaskFcst = function(object, theme = ggplot2::theme_minimal(), ...) {
  .data = NULL
  ggplot2::ggplot(object$data(), ggplot2::aes(x = .data[[object$col_roles$order]], y = .data[[object$target_names]])) +
    ggplot2::geom_line() +
    theme
}

#' @export
plot.TaskFcst = function(x, ...) {
  print(autoplot(x, ...))
}
