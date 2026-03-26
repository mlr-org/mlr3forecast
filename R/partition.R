#' @title Manually Partition into Training, Test and Validation Set
#'
#' @description
#' Creates a split of the row ids of a [Task] into a training and a test set, and optionally a validation set.
#'
#' @inheritParams mlr3::partition
#'
#' @export
#' @examples
#' task = tsk("airpassengers")
#' split = partition(task, ratio = 0.8)
partition.TaskFcst = function(task, ratio = 0.67) {
  task = task$clone(deep = TRUE)
  if (sum(ratio) >= 1) {
    error_input("Sum of 'ratio' must be smaller than 1")
  }

  if (length(ratio) == 1L) {
    ratio[2L] = 1 - ratio
  } else {
    ratio[3L] = 1 - (ratio[1L] + ratio[2L])
  }

  r1 = rsmp("fcst.holdout", ratio = ratio[1L])$instantiate(task)
  task$row_roles$use = r1$test_set(1L)
  r2 = rsmp("fcst.holdout", ratio = ratio[2L] / (1 - ratio[1L]))$instantiate(task)

  list(
    train = r1$train_set(1L),
    test = r2$train_set(1L),
    validation = r2$test_set(1L)
  )
}
