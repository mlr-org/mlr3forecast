#' @title BATS Forecast Learner
#'
#' @name mlr_learners_fcst.bats
#'
#' @description
#' BATS model.
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
        seasonal.periods = p_uty(default = NULL, tags = "train"),
        use.arma.errors = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        use.parallel = p_uty(tags = "train"),
        num.cores = p_int(1L, default = 2L, special_vals = list(NULL), tags = "train"),
        bc.lower = p_int(default = 0, tags = "train"),
        bc.upper = p_int(default = 1, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.bats",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "integer", "numeric"),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "BATS",
        man = "mlr3forecast::mlr_learners_fcst.bats"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      invoke(forecast::tbats, y = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.bats", LearnerFcstBats)
