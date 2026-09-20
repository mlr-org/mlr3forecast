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
#' @template task_generator_fcst
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
          custom_check = crate(function(x) {
            check_date(x, len = 1L, any.missing = FALSE) %check||% check_posixct(x, len = 1L, any.missing = FALSE)
          })
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
      data = data.table(time = rep(time, times = pv$k), y = y)
      key = character()
      if (pv$k > 1L) {
        set(data, j = "series", value = factor(rep(seq_len(pv$k), each = n)))
        setcolorder(data, "series")
        key = "series"
      }
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
