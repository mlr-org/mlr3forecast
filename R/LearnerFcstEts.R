#' @title ETS Forecast Learner
#'
#' @name mlr_learners_fcst.ets
#'
#' @description
#' ETS model.
#' Calls [forecast::ets()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.ets
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2002state", "hyndman2008admissible", "hyndman2008smoothing")`
#'
#' @export
#' @template seealso_learner
LearnerFcstEts = R6Class(
  "LearnerFcstEts",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        model = p_uty(default = "ZZZ", tags = "train", custom_check = crate(function(x) check_string(x, n.chars = 3L))),
        damped = p_lgl(default = NULL, special_vals = list(NULL), tags = "train"),
        alpha = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        beta = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        gamma = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        phi = p_dbl(default = NULL, special_vals = list(NULL), tags = "train"),
        additive.only = p_lgl(default = FALSE, tags = "train"),
        lambda = p_uty(tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train"),
        lower = p_uty(default = c(rep(1e-04, 3), 0.8), tags = "train"),
        upper = p_uty(default = c(rep(0.9999, 3), 0.98), tags = "train"),
        opt.crit = p_fct(default = "lik", levels = c("lik", "amse", "mse", "sigma", "mae"), tags = "train"),
        nmse = p_int(0L, 30L, default = 3, tags = "train"),
        bounds = p_fct(default = "both", levels = c("both", "usual", "admissible"), tags = "train"),
        ic = p_fct(default = "aicc", levels = c("aicc", "aic", "bic"), tags = "train"),
        restrict = p_lgl(default = TRUE, tags = "train"),
        allow.multiplicative.trend = p_lgl(default = FALSE, tags = "train"),
        na.action = p_fct(
          default = "na.contiguous",
          levels = c("na.contiguous", "na.interp", "na.fail"),
          tags = "train"
        )
      )

      super$initialize(
        id = "fcst.ets",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "integer", "numeric"),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "ETS",
        man = "mlr3forecast::mlr_learners_fcst.ets"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      invoke(forecast::ets, y = as.ts(task), .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.ets", LearnerFcstEts)
