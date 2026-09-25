#' @title ARIMA Forecast Task Generator
#'
#' @name mlr_task_generators_arima
#' @include zzz.R
#'
#' @description
#' A [TaskGenerator][mlr3::TaskGenerator] that simulates series from an ARIMA process via [stats::arima.sim()],
#' with autoregressive coefficients `ar`, moving average coefficients `ma`, differencing order `d`,
#' and innovation standard deviation `sd`.
#'
#' @templateVar id arima
#' @template task_generator
#'
#' @section Task structure:
#' The generated [TaskFcst] has the target `y` and the order column `time`, a regular index starting at `start` with
#' step `freq`.
#' A calendar `freq` such as `"month"` yields dates, a numeric `freq` yields the integers `1, ..., n` with `freq` as
#' the seasonal period.
#' With `k > 1`, `k` independent series are stacked into a keyed panel with the key column `series`, so `n` is the
#' length of each series and the task has `n * k` rows.
#'
#' @template seealso_task_generator
#' @export
#' @examples
#' generator = tgen("arima")
#' task = generator$generate(60)
#' task$head()
#'
#' # random walk, 3 series
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
          init = 0.7,
          tags = "required",
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE))
        ),
        d = p_int(0L, init = 0L, tags = "required"),
        ma = p_uty(
          init = numeric(),
          tags = "required",
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE))
        ),
        sd = p_dbl(0, init = 1, tags = "required"),
        k = p_int(1L, init = 1L, tags = "required"),
        freq = p_uty(init = "month", tags = "required", custom_check = check_freq),
        start = p_uty(
          init = as.Date("2000-01-01"),
          tags = "required",
          custom_check = crate(function(x) {
            check_date(x, len = 1L, any.missing = FALSE) %check||% check_posixct(x, len = 1L, any.missing = FALSE)
          })
        )
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

      freq = pv$freq
      time = if (is.character(freq)) {
        start = pv$start
        if (inherits(start, "Date") && grepl("sec|min|hour|DSTday", freq)) {
          start = as.POSIXct(start)
        }
        c(start, seq_order(start, freq, n - 1L))
      } else {
        seq_len(n)
      }

      data = map_dtr(
        seq_len(pv$k),
        function(i) {
          # arima.sim() prepends d zeros when integrating, keep the last n values
          y = tail(as.numeric(stats::arima.sim(model, n = n, sd = pv$sd)), n)
          data.table(time = time, y = y)
        },
        .idcol = "series"
      )
      key = if (pv$k > 1L) "series" else character()
      set(data, j = "series", value = if (pv$k > 1L) factor(data$series) else NULL)

      TaskFcst$new(
        sprintf("%s_%i", self$id, n),
        as_data_backend(data),
        target = "y",
        order = "time",
        key = key,
        freq = freq
      )
    }
  )
)

register_task_generator("arima", TaskGeneratorArima)
