#' @title ARFIMA Forecast Learner
#'
#' @name mlr_learners_fcst.arfima
#'
#' @description
#' ARFIMA model.
#' Calls [forecast::arfima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.arfima
#' @template learner
#'
#' @references
#' `r format_bib("haslett1989space", "hyndman2018automatic")`
#'
#' @export
#' @template seealso_learner
LearnerFcstArfima = R6Class(
  "LearnerFcstArfima",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        drange = p_uty(default = c(0, 0.5), tags = "train"),
        estim = p_fct(default = "mle", levels = c("mle", "ls"), tags = "train"),
        lambda = p_uty(default = NULL, tags = "train"),
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
        id = "fcst.arfima",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "ARFIMA",
        man = "mlr3forecast::mlr_learners_fcst.arfima"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      xreg = NULL
      if (length(task$feature_names) > 0L) {
        xreg = as.matrix(task$data(cols = task$feature_names))
      }
      invoke(forecast::arfima, y = as.ts(task), xreg = xreg, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.arfima", LearnerFcstArfima)
