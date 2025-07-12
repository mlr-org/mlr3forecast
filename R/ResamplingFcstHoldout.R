#' @title Forecast Holdout Resampling
#'
#' @name mlr_resamplings_fcst.holdout
#'
#' @description
#' Splits data into a training set and a test set.
#' Parameter `ratio` determines the ratio of observation going into the training set (default: 2/3).
#'
#' @templateVar id fcst.cv
#' @template resampling
#'
#' @section Parameters:
#' * `ratio` (`numeric(1)`)\cr
#'   Ratio of observations to put into the training set.
#'   Mutually exclusive with parameter `n`.
#' * `n` (`integer(1)`)\cr
#'   Number of observations to put into the training set.
#'   If negative, the absolute value determines the number of observations in the test set.
#'   Mutually exclusive with parameter `ratio`.
#'
#' @template seealso_resampling
#' @export
#' @examples
#' # Create a task with 10 observations
#' task = tsk("airpassengers")
#' task$filter(1:10)
#'
#' # Instantiate Resampling
#' holdout = rsmp("fcst.holdout", ratio = 0.5)
#' holdout$instantiate(task)
#'
#' # Individual sets:
#' holdout$train_set(1)
#' holdout$test_set(1)
#'
#' # Disjunct sets:
#' intersect(holdout$train_set(1), holdout$test_set(1))
#'
#' # Internal storage:
#' holdout$instance # simple list
ResamplingFcstHoldout = R6Class(
  "ResamplingFcstHoldout",
  inherit = Resampling,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        ratio = p_dbl(0, 1),
        n = p_int()
      )

      super$initialize(
        id = "fcst.holdout",
        label = "Time Series Holdout",
        param_set = param_set,
        man = "mlr3forecast::mlr_resamplings_fcst.holdout"
      )
    }
  ),

  active = list(
    #' @template field_iters
    iters = function(rhs) {
      assert_ro_binding(rhs)
      1L
    }
  ),

  private = list(
    .sample = function(ids, task, ...) {
      if ("ordered" %nin% task$properties) {
        stopf("Resampling '%s' requires an ordered task, but Task '%s' has no order.", self$id, task$id)
      }

      pars = self$param_set$get_values()
      ratio = pars$ratio
      n = pars$n
      n_obs = task$nrow

      has_ratio = !is.null(ratio)
      if (!xor(!has_ratio, is.null(n))) {
        stopf("Either parameter `ratio` (x)or `n` must be provided.")
      }
      if (has_ratio) {
        nr = round(n_obs * ratio)
      } else if (n > 0L) {
        nr = min(n_obs, n)
      } else {
        nr = max(n_obs + n, 0L)
      }

      order_cols = task$col_roles$order
      key_cols = task$col_roles$key
      has_key_cols = length(key_cols) > 0L
      dt = task$backend$data(rows = ids, cols = c(task$backend$primary_key, order_cols, key_cols))
      if (has_key_cols) {
        setnames(dt, "..row_id", "row_id")
        setorderv(dt, c(key_cols, order_cols))
        n_groups = uniqueN(dt, by = key_cols)
        nr = if (has_ratio) nr %/% n_groups else nr
        list(
          train = dt[, .SD[1:nr], by = key_cols][, row_id],
          test = dt[, .SD[(nr + 1L):.N], by = key_cols][, row_id]
        )
      } else {
        setnames(dt, c("row_id", "order"))
        setorderv(dt, "order")
        list(train = dt[1:nr, row_id], test = dt[(nr + 1L):.N, row_id])
      }
    },

    .sample_ids = function(ids, task, ...) {
      if ("ordered" %nin% task$properties) {
        stopf("Resampling '%s' requires an ordered task, but Task '%s' has no order.", self$id, task$id)
      }

      pars = self$param_set$get_values()
      ratio = pars$ratio
      n = pars$n
      n_obs = length(ids)

      has_ratio = !is.null(ratio)
      if (!xor(!has_ratio, is.null(n))) {
        stopf("Either parameter `ratio` (x)or `n` must be provided.")
      }
      if (has_ratio) {
        nr = round(n_obs * ratio)
      } else if (n > 0L) {
        nr = min(n_obs, n)
      } else {
        nr = max(n_obs + n, 0L)
      }

      ids = sort(ids)
      ii = ids[1:nr]
      list(train = ii, test = ids[(nr + 1L):n_obs])
    },

    .get_train = function(i) {
      self$instance$train
    },

    .get_test = function(i) {
      self$instance$test
    },

    .combine = function(instances) {
      list(train = do.call(c, map(instances, "train")), test = do.call(c, map(instances, "test")))
    }
  )
)

#' @include zzz.R
register_resampling("fcst.holdout", ResamplingFcstHoldout)
