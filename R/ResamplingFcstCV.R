#' @title Forecast Cross-Validation Resampling
#'
#' @name mlr_resamplings_fcst.cv
#'
#' @description
#' Splits data using a `folds`-folds (default: 5 folds) rolling window cross-validation.
#'
#' @templateVar id fcst.cv
#' @template resampling
#'
#' @section Parameters:
#' * `horizon` (`integer(1)`)\cr
#'   Forecasting horizon in the test sets, i.e. number of test samples for each fold.
#' * `folds` (`integer(1)`)\cr
#'   Number of folds.
#' * `step_size` (`integer(1)`)\cr
#'   Step size between windows.
#' * `window_size` (`integer(1)`)\cr
#'   (Minimal) Size of the rolling window.
#' * `fixed_window` (`logical(1)`)\cr
#'   Should a fixed sized window be used? If `FALSE` an expanding window is used.
#'
#' @references
#' `r format_bib("bergmeir_2018")`
#'
#' @template seealso_resampling
#' @export
#' @examples
#' # Create a task with 10 observations
#' task = tsk("airpassengers")
#' task$filter(1:20)
#'
#' # Instantiate Resampling
#' cv = rsmp("fcst.cv", folds = 3, fixed_window = FALSE)
#' cv$instantiate(task)
#'
#' # Individual sets:
#' cv$train_set(1)
#' cv$test_set(1)
#' intersect(cv$train_set(1), cv$test_set(1))
#'
#' # Internal storage:
#' cv$instance #  list
ResamplingFcstCV = R6Class(
  "ResamplingFcstCV",
  inherit = Resampling,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        horizon = p_int(1L, tags = "required"),
        folds = p_int(1L, tags = "required"),
        step_size = p_int(1L, tags = "required"),
        window_size = p_int(2L, tags = "required"),
        fixed_window = p_lgl(tags = "required")
      )
      param_set$set_values(
        horizon = 1L,
        folds = 5L,
        step_size = 1L,
        window_size = 3L,
        fixed_window = FALSE
      )

      super$initialize(
        id = "fcst.cv",
        label = "Time Series Cross-Validation",
        param_set = param_set,
        man = "mlr3forecast::mlr_resamplings_fcst.cv"
      )
    }
  ),

  active = list(
    #' @template field_iters
    iters = function(rhs) {
      assert_ro_binding(rhs)
      pars = self$param_set$get_values()
      as.integer(pars$folds)
    }
  ),

  private = list(
    .sample = function(ids, task, ...) {
      if ("ordered" %nin% task$properties) {
        stopf("Resampling '%s' requires an ordered task, but Task '%s' has no order.", self$id, task$id)
      }

      pars = self$param_set$get_values()
      window_size = pars$window_size
      horizon = pars$horizon
      fixed_window = pars$fixed_window
      step_size = pars$step_size
      folds = pars$folds

      col_roles = task$col_roles
      order_cols = col_roles$order
      key_cols = col_roles$key
      has_key = length(key_cols) > 0L

      dt = task$backend$data(
        rows = ids,
        cols = c(task$backend$primary_key, order_cols, key_cols)
      )
      setnames(dt, "..row_id", "row_id")

      if (!has_key) {
        setorderv(dt, order_cols)
        n = nrow(dt)
        train_end = rev(seq(from = n - horizon, by = -step_size, length.out = folds))
        if (fixed_window) {
          train_ids = map(train_end, function(i) dt[(i - window_size + 1L):i, "row_id"][[1L]])
        } else {
          train_ids = map(train_end, function(i) dt[1L:i, "row_id"][[1L]])
        }
        test_ids = map(train_end, function(i) dt[(i + 1L):(i + horizon), "row_id"][[1L]])
        return(list(train = train_ids, test = test_ids))
      }

      setorderv(dt, c(key_cols, order_cols))
      ids = dt[,
        {
          train_end = rev(seq(from = .N - horizon, by = -step_size, length.out = folds))
          if (fixed_window) {
            train_ids = map(train_end, function(i) .SD[(i - window_size + 1L):i, "row_id"][[1L]])
          } else {
            train_ids = map(train_end, function(i) .SD[1L:i, "row_id"][[1L]])
          }
          test_ids = map(train_end, function(i) .SD[(i + 1L):(i + horizon), "row_id"][[1L]])
          list(train_ids = train_ids, test_ids = test_ids)
        },
        by = key_cols
      ][, c("train_ids", "test_ids")]
      list(train = ids$train_ids, test = ids$test_ids)
    },

    .sample_ids = function(ids, task, ...) {
      if ("ordered" %nin% task$properties) {
        stopf("Resampling '%s' requires an ordered task, but Task '%s' has no order.", self$id, task$id)
      }

      pars = self$param_set$get_values()
      window_size = pars$window_size
      horizon = pars$horizon

      ids = sort(ids)
      train_end = ids[ids <= (max(ids) - horizon) & ids >= window_size]
      train_end = seq(from = train_end[length(train_end)], by = -pars$step_size, length.out = pars$folds)
      if (pars$fixed_window) {
        train_ids = map(train_end, function(x) (x - window_size + 1L):x)
      } else {
        train_ids = map(train_end, function(x) ids[1L]:x)
      }
      test_ids = map(train_ids, function(x) {
        n = length(x)
        (x[n] + 1L):(x[n] + horizon)
      })
      list(train = train_ids, test = test_ids)
    },

    .get_train = function(i) {
      self$instance$train[[i]]
    },

    .get_test = function(i) {
      self$instance$test[[i]]
    },

    .combine = function(instances) {
      rbindlist(instances, use.names = TRUE)
    },

    deep_clone = function(name, value) {
      switch(name, instance = copy(value), param_set = value$clone(deep = TRUE), value)
    }
  )
)

#' @include zzz.R
register_resampling("fcst.cv", ResamplingFcstCV)
