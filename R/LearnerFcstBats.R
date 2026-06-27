#' @title BATS Forecast Learner
#'
#' @name mlr_learners_fcst.bats
#'
#' @description
#' Exponential smoothing state space model with Box-Cox transformation, ARMA errors, Trend and Seasonal components
#' (BATS) model.
#' Calls [forecast::bats()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.bats
#' @template learner
#'
#' @references
#' `r format_bib("livera2011complex")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstBats = R6Class(
  "LearnerFcstBats",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        use.box.cox = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        use.trend = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        use.damped.trend = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        seasonal.periods = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, lower = 1, null.ok = TRUE))
        ),
        use.arma.errors = p_lgl(default = TRUE, tags = "train"),
        use.parallel = p_lgl(tags = "train"),
        num.cores = p_int(1L, default = 2L, special_vals = list(NULL), tags = "train", depends = quote(use.parallel == TRUE)),
        bc.lower = p_dbl(default = 0, tags = "train"),
        bc.upper = p_dbl(default = 1, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = "fcst.bats",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "BATS",
        man = "mlr3forecast::mlr_learners_fcst.bats"
      )
    }
  ),

  private = list(
    .fn = "bats"
  )
)

#' @include zzz.R
register_learner("fcst.bats", LearnerFcstBats)
