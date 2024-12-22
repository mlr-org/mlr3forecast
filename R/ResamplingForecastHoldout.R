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
    .sample = function(ids, ...) {
      pars = self$param_set$get_values()
      n = length(ids)
      has_ratio = !is.null(pars$ratio)
      if (!xor(!has_ratio, is.null(pars$n))) {
        stopf("Either parameter `ratio` (x)or `n` must be provided.")
      }
      if (has_ratio) {
        nr = round(n * pars$ratio)
      } else if (pars$n > 0L) {
        nr = min(n, pars$n)
      } else {
        nr = max(n + pars$n, 0L)
      }
      ii = ids[1:nr]
      list(train = ii, test = ids[(nr + 1L):n])
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
