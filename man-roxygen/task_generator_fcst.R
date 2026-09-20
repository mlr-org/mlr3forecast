#' @section Task structure:
#' The generated [TaskFcst] has the target `y` and the order column `time`, a regular index starting at `start` with
#' step `freq`.
#' A calendar `freq` such as `"month"` yields dates, a numeric `freq` yields the integers `1, ..., n` with `freq` as
#' the seasonal period.
#' With `k > 1`, `k` independent series are stacked into a keyed panel with the key column `series`, so `n` is the
#' length of each series and the task has `n * k` rows.
