#' @title ARIMA
#'
#' @name mlr_learners_fcst.arima
#'
#' @description
#' ARIMA model.
#' Calls [forecast::Arima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.arima
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018fpp")`
#'
#' @export
#' @template seealso_learner
LearnerFcstArima = R6Class(
  "LearnerFcstArima",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        order = p_uty(
          default = c(0L, 0L, 0L),
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 0L, len = 3L))
        ),
        seasonal = p_uty(
          default = c(0L, 0L, 0L),
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 0L, len = 3L))
        ),
        include.mean = p_lgl(default = TRUE, tags = "train"),
        include.drift = p_lgl(default = FALSE, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train"),
        method = p_fct(c("CSS-ML", "ML", "CSS"), default = "CSS-ML", tags = "train")
      )

      super$initialize(
        id = "fcst.arima",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "logical", "integer", "numeric"),
        properties = "missings",
        packages = c("mlr3forecast", "forecast"),
        label = "ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.arima"
      )
    }
  ),

  private = list(
    .train = function(task) {
      if ("ordered" %nin% task$properties) {
        stopf("%s learner requires an ordered task.", self$id)
      }
      private$.max_index = max(task$data(cols = task$col_roles$order)[[1L]])
      pv = self$param_set$get_values(tags = "train")

      xreg = NULL
      if (length(task$feature_names) > 0L) {
        xreg = as.matrix(task$data(cols = fcst_feature_names(task)))
      }
      invoke(forecast::Arima, y = as.ts(task), xreg = xreg, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.arima", LearnerFcstArima)
