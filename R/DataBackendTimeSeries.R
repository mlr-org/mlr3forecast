#' @title DataBackend for time series
#'
#' @description
#' [DataBackend] for \CRANpkg{data.table} which serves as an efficient in-memory data base.
#'
#' @export
#' @examplesIf requireNamespace("tsbox", quietly = TRUE)
#' data = tsbox::ts_dt(AirPassengers)
#' data[, id := 1:.N]
#' b = DataBackendTimeSeries$new(data = data, primary_key = "id", index = "time")
DataBackendTimeSeries = R6Class("DataBackendTimeSeries",
  inherit = DataBackendDataTable,
  cloneable = FALSE,
  public = list(
    index = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' Note that `DataBackendDataTable` does not copy the input data, while `as_data_backend()` calls [data.table::copy()].
    #' `as_data_backend()` also takes care about casting to a `data.table()` and adds a primary key column if necessary.
    #'
    #' @param data ([data.table::data.table()])\cr
    #'   The input [data.table()].
    initialize = function(data, primary_key, index) {
      # NOTE: currently in the super class sets the primary_key as the data.table key
      super$initialize(data, primary_key)
      if (!is.null(index) && index %nin% names(data)) {
        stopf("index '%s' not in 'data'", primary_key)
      }
      self$index = index
    }
  )
)
