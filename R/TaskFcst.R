#' @export
#' @examplesIf require_namespaces("tsbox", quietly = TRUE)
#' airpassengers = tsbox::ts_dt(AirPassengers)
#' task = as_task_fcst(airpassengers, target = "value", index = "time")
#' task$task_type
#' task$formula()
#' task$truth()
#' task$data(rows = 1:3)
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

      # TODO: seems very hacky
      private$.col_roles$feature = setdiff(private$.col_roles$feature, index)
      # TODO: should it every be null?
      self$col_roles$index = index %??% "time"

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
    },

    #' @description
    #' Returns the `index` column.
    index_col = function(rows = NULL) {
      rows = rows %??% self$row_roles$use
      self$backend$data(rows, self$index)
    }
  ),

  active = list(
    #' @field date_col (`character(1)`)\cr
    #' Returns the index column.
    index = function() {
      self$backend$index
    }
  )
)
