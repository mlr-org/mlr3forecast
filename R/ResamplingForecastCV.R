#' @title Forecast Cross-Validation Resampling
#'
#' @name mlr_resamplings_forecast_cv
#'
#' @description
#' Splits data using a `folds`-folds (default: 10 folds) rolling window cross-validation.
#'
#' @templateVar id forecast_cv
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
#' * `fixed_window` (`logial(1)`)\cr
#'   Should a fixed sized window be used? If `FALSE` an expanding window is used.
#'
#' @references
#' `r format_bib("bergmeir_2018")`
#'
#' @template seealso_resampling
#' @export
#' @examples
#' # Create a task with 10 observations
#' task = tsk("penguins")
#' task$filter(1:20)
#'
#' # Instantiate Resampling
#' cv = rsmp("forecast_cv", folds = 3, fixed_window = FALSE)
#' cv$instantiate(task)
#'
#' # Individual sets:
#' cv$train_set(1)
#' cv$test_set(1)
#' intersect(cv$train_set(1), cv$test_set(1))
#'
#' # Internal storage:
#' cv$instance #  list
ResamplingForecastCV = R6Class("ResamplingForecastCV",
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
        id = "forecast_cv",
        label = "Time Series Cross-Validation",
        param_set = param_set,
        man = "mlr3forecast::mlr_resamplings_forecast_cv"
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
    .sample = function(ids, ...) {
      pars = self$param_set$get_values()
      ids = sort(ids)
      train_end = ids[ids <= (max(ids) - pars$horizon) & ids >= pars$window_size]
      train_end = seq.int(
        from = train_end[length(train_end)],
        by = -pars$step_size,
        length.out = pars$folds
      )
      if (!pars$fixed_window) {
        train_ids = map(train_end, function(x) ids[1L]:x)
      } else {
        train_ids = map(train_end, function(x) (x - pars$window_size + 1L):x)
      }
      test_ids = map(train_ids, function(x) (x[length(x)] + 1L):(x[length(x)] + pars$horizon))
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
      switch(name,
        "instance" = copy(value),
        "param_set" = value$clone(deep = TRUE),
        value
      )
    }
  )
)

#' @include zzz.R
register_resampling("forecast_cv", ResamplingForecastCV)
