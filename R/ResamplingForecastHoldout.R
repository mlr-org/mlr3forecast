#' @title Forecast Holdout Resampling
#'
#' @name mlr_resamplings_forecast_holdout
#'
#' @description
#' Splits data into a training set and a test set.
#' Parameter `ratio` determines the ratio of observation going into the training set (default: 2/3).
#'
#' @templateVar id forecast_cv
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
#' task = tsk("penguins")
#' task$filter(1:10)
#'
#' # Instantiate Resampling
#' holdout = rsmp("forecast_holdout", ratio = 0.5)
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
ResamplingForecastHoldout = R6Class("ResamplingForecastHoldout",
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
        id = "forecast_holdout",
        label = "Time Series Holdout",
        param_set = param_set,
        man = "mlr3forecast::mlr_resamplings_forecast_holdout"
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

    .sample_new = function(ids, task, ...) {
      pars = self$param_set$get_values()
      ratio = pars$ratio
      n = pars$n
      n_obs = task$nrow

      has_ratio = !is.null(ratio)
      if (!xor(!has_ratio, is.null(n))) {
        stopf("Either parameter `ratio` (x)or `n` must be provided.")
      }
      group_cols = task$col_roles$group
      has_group = length(group_cols) > 0L
      if (has_ratio) {
        nr = round(n_obs * ratio)
        if (has_group) {
          nr = floor(nr / length(ids))
        }
      } else if (n > 0L) {
        nr = min(n_obs, n)
      } else {
        nr = max(n_obs + n, 0L)
      }

      # for ratio this needs to be adjusted for i.e. divided by the groups,
      # n is fine, but would have to be documented for group usage
      group_cols = task$col_roles$group
      # note: by = NULL also works, could make it type consistent
      if (length(group_cols) > 0L) {
        tab = task$backend$data(rows = task$row_ids, cols = c(task$backend$primary_key, group_cols))
        setnames(tab, c("row_id", "group"))
        # assumes its sorted correct
        res = list(
          train = tab[, .SD[1:nr], by = group][, row_id],
          test = tab[, .SD[(nr + 1L):.N], by = group][, row_id]
        )
        browser()
        return(res)
      }

      browser()

      if (TRUE) {
        ids = sort(ids)
        ii = ids[1:nr]
        list(train = ii, test = ids[(nr + 1L):n_obs])
      } else {
        # check when this is even needed
        order = row_id = NULL
        order_cols = task$col_roles$order
        tab = task$backend$data(rows = ids, cols = c(task$backend$primary_key, order_cols))
        setnames(tab, c("row_id", "order"))
        setorder(tab, order)
        list(
          train = tab[1:nr, row_id],
          test = tab[(nr + 1L):.N, row_id]
        )
      }
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
register_resampling("forecast_holdout", ResamplingForecastHoldout)
