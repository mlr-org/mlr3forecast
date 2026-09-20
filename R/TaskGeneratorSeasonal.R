#' @title Trend and Seasonality Forecast Task Generator
#'
#' @name mlr_task_generators_seasonal
#' @include zzz.R
#'
#' @description
#' A [TaskGenerator][mlr3::TaskGenerator] for series composed of a linear trend, a sinusoidal seasonal pattern,
#' and Gaussian noise.
#' At time step `t = 1, ..., n`, the trend is `level + trend * t`, the seasonal component is
#' `amplitude * sin(2 * pi * t / period)`, and the noise has standard deviation `sd`.
#' For `type = "additive"`, the seasonal component and the noise are added to the trend.
#' For `type = "multiplicative"`, both are scaled by the ratio of the trend to `level`, so the seasonal swings and
#' the noise grow proportionally with the trend, as in the classic airline passengers data.
#' In both cases, `amplitude` and `sd` are on the scale of the target at the start of the series.
#' The multiplicative type requires a positive `level`.
#' If `period` is not set, it is derived from `freq` (e.g. 12 for monthly data).
#' The generated [TaskFcst] has the target `y` and a regular time index built from `start` and `freq`.
#' A calendar `freq` such as `"month"` yields a `date` column, whereas a numeric `freq` yields an integer `index`
#' column with `freq` as the seasonal period.
#' With `k > 1`, `k` independent draws are stacked into a keyed panel with the key column `series`, so that `n` is
#' the length of each series and the task has `n * k` rows.
#' The parameters are initialized to `level = 100`, `trend = 1`, `amplitude = 10`, `sd = 1`, `type = "additive"`,
#' `k = 1`, `freq = "month"`, and `start = as.Date("2000-01-01")`.
#'
#' @templateVar id seasonal
#' @template task_generator
#'
#' @template seealso_task_generator
#' @export
#' @examples
#' generator = tgen("seasonal")
#' task = generator$generate(48)
#' task$head()
#'
#' # keyed panel of 3 series with multiplicative seasonality
#' generator = tgen("seasonal", type = "multiplicative", amplitude = 20, k = 3L)
#' task = generator$generate(36)
#' task
TaskGeneratorSeasonal = R6Class(
  "TaskGeneratorSeasonal",
  inherit = TaskGenerator,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        level = p_dbl(tags = "required"),
        trend = p_dbl(tags = "required"),
        amplitude = p_dbl(0, tags = "required"),
        period = p_dbl(1),
        sd = p_dbl(0, tags = "required"),
        type = p_fct(c("additive", "multiplicative"), tags = "required"),
        k = p_int(1L, tags = "required"),
        freq = p_uty(tags = "required", custom_check = check_freq),
        start = p_uty(
          tags = "required",
          custom_check = crate(function(x) check_multi_class(x, c("Date", "POSIXct")))
        )
      )
      param_set$set_values(
        level = 100,
        trend = 1,
        amplitude = 10,
        sd = 1,
        type = "additive",
        k = 1L,
        freq = "month",
        start = as.Date("2000-01-01")
      )

      super$initialize(
        id = "seasonal",
        task_type = "fcst",
        param_set = param_set,
        label = "Trend and Seasonality Simulation",
        man = "mlr3forecast::mlr_task_generators_seasonal"
      )
    }
  ),

  private = list(
    .generate = function(n) {
      pv = self$param_set$get_values()
      if (pv$type == "multiplicative" && pv$level <= 0) {
        error_config("Multiplicative seasonality requires a positive 'level', but 'level' is %g", pv$level)
      }
      period = pv$period %??% freq_to_period(pv$freq)
      tt = seq_len(n)
      base = pv$level + pv$trend * tt
      season = pv$amplitude * sin(2 * pi * tt / period)
      y = unlist(map(seq_len(pv$k), function(i) {
        deviation = season + stats::rnorm(n, sd = pv$sd)
        if (pv$type == "additive") base + deviation else base * (1 + deviation / pv$level)
      }))
      make_generated_task(sprintf("%s_%i", self$id, n), y, n, pv$k, pv$freq, pv$start)
    }
  )
)

register_task_generator("seasonal", TaskGeneratorSeasonal)
