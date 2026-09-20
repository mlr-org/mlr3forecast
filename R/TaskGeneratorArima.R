#' @title ARIMA Forecast Task Generator
#'
#' @name mlr_task_generators_arima
#' @include zzz.R
#'
#' @description
#' A [TaskGenerator][mlr3::TaskGenerator] that simulates series from an ARIMA process via [stats::arima.sim()].
#' The autoregressive and moving average coefficients are given by `ar` and `ma`, the order of differencing by `d`,
#' and the standard deviation of the Gaussian innovations by `sd`.
#' The generated [TaskFcst] has the target `y` and a regular time index built from `start` and `freq`.
#' A calendar `freq` such as `"month"` yields a `date` column, whereas a numeric `freq` yields an integer `index`
#' column with `freq` as the seasonal period.
#' With `k > 1`, `k` independent realizations of the process are stacked into a keyed panel with the key column
#' `series`, so that `n` is the length of each series and the task has `n * k` rows.
#' The parameters are initialized to an AR(1) process with `ar = 0.7`, `d = 0`, `ma = numeric()`, `sd = 1`, `k = 1`,
#' `freq = "month"`, and `start = as.Date("2000-01-01")`.
#'
#' @templateVar id arima
#' @template task_generator
#'
#' @template seealso_task_generator
#' @export
#' @examples
#' generator = tgen("arima")
#' task = generator$generate(60)
#' task$head()
#'
#' # random walk with drift-free innovations, 3 series
#' generator = tgen("arima", ar = numeric(), d = 1L, k = 3L)
#' task = generator$generate(24)
#' task
TaskGeneratorArima = R6Class(
  "TaskGeneratorArima",
  inherit = TaskGenerator,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        ar = p_uty(
          tags = "required",
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE))
        ),
        d = p_int(0L, tags = "required"),
        ma = p_uty(
          tags = "required",
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE))
        ),
        sd = p_dbl(0, tags = "required"),
        k = p_int(1L, tags = "required"),
        freq = p_uty(tags = "required", custom_check = check_freq),
        start = p_uty(
          tags = "required",
          custom_check = crate(function(x) check_multi_class(x, c("Date", "POSIXct")))
        )
      )
      param_set$set_values(
        ar = 0.7,
        d = 0L,
        ma = numeric(),
        sd = 1,
        k = 1L,
        freq = "month",
        start = as.Date("2000-01-01")
      )

      super$initialize(
        id = "arima",
        task_type = "fcst",
        param_set = param_set,
        label = "ARIMA Simulation",
        man = "mlr3forecast::mlr_task_generators_arima"
      )
    }
  ),

  private = list(
    .generate = function(n) {
      pv = self$param_set$get_values()
      model = list(order = c(length(pv$ar), pv$d, length(pv$ma)), ar = pv$ar, ma = pv$ma)
      # arima.sim() prepends d zeros when integrating, keep the last n values
      y = unlist(map(seq_len(pv$k), function(i) tail(as.numeric(stats::arima.sim(model, n = n, sd = pv$sd)), n)))
      make_generated_task(sprintf("%s_%i", self$id, n), y, n, pv$k, pv$freq, pv$start)
    }
  )
)

register_task_generator("arima", TaskGeneratorArima)
