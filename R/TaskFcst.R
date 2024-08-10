#' @export
#' @examples
#' task = as_task_fcst(tsbox::ts_dt(AirPassengers), target = "value", index = "time")
#' task$task_type
#' task$formula()
#' task$truth()
#' task$data(rows = 1:3, cols = task$feature_names[1:2])
TaskFcst = R6::R6Class("TaskFcst",
  inherit = TaskSupervised,
  public = list(
    initialize = function(id, backend, target, index, label = NA_character_, extra_args = list()) {
      assert_string(target)
      assert_string(index)

      super$initialize(
        id = id,
        task_type = "fcst",
        backend = backend,
        target = target,
        label = label,
        extra_args = extra_args
      )

      type = self$col_info[id == target]$type
      if (type %nin% c("integer", "numeric")) {
        stopf("Target column '%s' must be numeric", target)
      }
    },

    #' @description
    #' True response for specified `row_ids`. Format depends on the task type.
    #' Defaults to all rows with role "use".
    #' @returns `numeric()`.
    truth = function(rows = NULL) {
      super$truth(rows)[[1L]]
    }
  )
)
