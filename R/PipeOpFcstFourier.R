#' @title Create Fourier Features for Seasonality
#' @name mlr_pipeops_fcst.fourier
#'
#' @description
#' Creates pairs of Fourier (harmonic) terms `sin(2 * pi * k * t / period)` and `cos(2 * pi * k * t / period)` as new
#' feature columns, for `k = 1, ..., K` harmonics per seasonal `period`, where `t` counts steps of the task's `freq`
#' since a fixed origin. They encode seasonality as a flexible alternative to seasonal lags, in particular for long or
#' non-integer periods and multiple seasonalities at once.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreprocSimple], as well as the following
#' parameters:
#' * `period` :: `character()` | `numeric()` | `NULL`\cr
#'   Seasonal period(s), in number of observations per cycle, or cycle name(s) such as `"year"` resolved against the
#'   task's frequency. May be non-integer and may contain multiple periods for multiple seasonalities. If `NULL`
#'   (default), the default derived from the task's `freq` is used.
#' * `K` :: `integer()`\cr
#'   Number of Fourier harmonics per `period`. Either a single value recycled to all periods, or one value per period.
#'   Each `K` must satisfy `2 * K <= period`. Default `1L`.
#'
#' @references
#' `r format_bib("livera2011complex", "hyndman2008automatic")`
#'
#' @template section_period
#'
#' @export
#' @examples
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' po = po("fcst.fourier", period = 12, K = 3L)
#' new_task = po$train(list(task))[[1L]]
#' new_task$head()
PipeOpFcstFourier = R6Class(
  "PipeOpFcstFourier",
  inherit = PipeOpTaskPreprocSimple,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.fourier"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.fourier", param_vals = list()) {
      param_set = ps(
        period = p_uty(
          tags = c("train", "predict"),
          custom_check = crate(function(x) check_period(x, multiple = TRUE))
        ),
        K = p_uty(
          init = 1L,
          tags = c("train", "predict"),
          custom_check = crate(function(x) check_integerish(x, lower = 1L, any.missing = FALSE, min.len = 1L))
        )
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        can_subset_cols = FALSE,
        tags = "fcst"
      )
    }
  ),

  private = list(
    .get_state = function(task) list(),

    .transform = function(task) {
      pv = self$param_set$get_values(tags = "train")
      period = resolve_period(pv$period, task$freq)
      K = pv$K
      if (length(K) == 1L) {
        K = rep(K, length(period))
      }
      if (length(K) != length(period)) {
        error_input("`K` must be a single value or have the same length as `period`.")
      }
      if (any(2 * K > period)) {
        error_input("`K` must not be greater than `period / 2`. Set a smaller `K` or a larger `period`.")
      }

      times = epoch_steps(task$data(cols = task$col_roles$order)[[1L]], task$freq)
      task$cbind(as.data.table(fourier_terms(times, period, K)))
    }
  )
)

# port of forecast:::fourier(), evaluating Fourier terms at the given time positions.
fourier_terms = function(times, period, K) {
  k = sequence(K)
  per = rep(period, K)
  p = k / per
  labels = paste(paste0(c("S", "C"), rep(k, each = 2L)), rep(round(per), each = 2L), sep = "_")
  # remove equivalent harmonics arising from overlapping seasonal periods
  dup = duplicated(p)
  k = k[!dup]
  per = per[!dup]
  p = p[!dup]
  labels = labels[!rep(dup, each = 2L)]
  # sine terms that are identically zero (2 * p integer) are dropped
  keep_sin = abs(2 * p - round(2 * p)) > .Machine$double.eps
  keep = rep(TRUE, 2L * length(p))
  keep[2L * seq_along(p) - 1L] = keep_sin
  X = matrix(NA_real_, nrow = length(times), ncol = sum(keep), dimnames = list(NULL, labels[keep]))
  jj = 0L
  for (j in seq_along(p)) {
    phase = (k[j] * times) %% per[j] / per[j]
    if (keep_sin[j]) {
      jj = jj + 1L
      X[, jj] = sinpi(2 * phase)
    }
    jj = jj + 1L
    X[, jj] = cospi(2 * phase)
  }
  X
}

#' @include zzz.R
register_po("fcst.fourier", PipeOpFcstFourier)
