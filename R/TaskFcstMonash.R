#' @title Monash Forecasting Repository task
#'
#' @name mlr_tasks_monash
#' @format [R6::R6Class] inheriting from [TaskFcst].
#'
#' @description
#' Downloads a dataset from the Monash Forecasting Repository and converts it to a forecast task.
#'
#' @param dataset (`character(1)`)\cr
#'   The dataset ID, e.g. `"m3_yearly"`.
#'   The IDs follow the names used by the Monash Forecasting Repository.
#'   Variants whose IDs end in `"_with_missing_values"` cannot be converted to a forecast task and can only be
#'   retrieved with [download_zenodo_record()].
#' @param id (`character(1)`)\cr
#'   The task ID.
#'   Defaults to `dataset`.
#'
#' @section Dictionary:
#' This task can be instantiated via the [dictionary][mlr3misc::Dictionary] [mlr_tasks][mlr3::mlr_tasks]
#' or with the associated sugar function [tsk()][mlr3::tsk]:
#' ```
#' mlr_tasks$get("monash", dataset = "m3_yearly")
#' tsk("monash", dataset = "m3_yearly")
#' ```
#'
#' @references
#' `r format_bib("godahewa2021monash")`
#'
#' @template seealso_task
#' @family Task
NULL

load_task_monash = function(dataset = NULL, id = dataset) {
  if (is.null(dataset)) {
    stop(errorCondition("Argument 'dataset' must be provided.", class = "missingDefaultError")) # nolint
  }
  info = resolve_monash_dataset(dataset) # nolint
  assert_string(id, min.chars = 1L)
  if (info$has_missing) {
    error_input(
      "Dataset '%s' contains missing target values and cannot be converted to a forecast task.",
      dataset
    )
  }

  as_task_fcst(download_zenodo_record(dataset = dataset), id = id)
}

#' @include monash_datasets.R zzz.R
register_task("monash", load_task_monash)
