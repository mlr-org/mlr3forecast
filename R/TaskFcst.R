#' @export
#' @examplesIf requireNamespace("tsbox", quietly = TRUE)
#' airpassengers = tsbox::ts_dt(AirPassengers)
#' task = as_task_fcst(airpassengers, target = "value", index = "time", freq = "month")
#' task$task_type
#' task$formula()
#' task$truth()
#' task$data(rows = 1:3)
TaskFcst = R6::R6Class("TaskFcst",
  inherit = TaskSupervised,
  public = list(
    index = NULL,
    freq = NULL,

    initialize = function(id, backend, target, index, freq, label = NA_character_, extra_args = list()) { # nolint
      assert_string(target)
      assert_string(index)
      assert_string(freq)

      super$initialize(
        id = id,
        task_type = "fcst",
        backend = backend,
        target = target,
        label = label,
        extra_args = extra_args
      )
      self$index = index
      self$freq = freq

      # TODO: seems very hacky
      private$.col_roles$feature = setdiff(private$.col_roles$feature, index)
      # TODO: should it every be null?
      self$col_roles$index = index %??% "time"

      type = self$col_info[id == target]$type
      if (type %nin% c("integer", "numeric")) {
        stopf("Target column '%s' must be numeric", target)
      }
    },

    print = function(...) {
      super$print(...)
      catn(str_indent("* Index:", self$index))
      catn(str_indent("* Frequency:", self$freq))
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
