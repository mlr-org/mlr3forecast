#' @title ETS
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
#' `r format_bib("hyndman2018automatic")`
#'
#' @export
#' @template seealso_learner
LearnerFcstEts = R6Class("LearnerFcstEts",
  inherit = LearnerRegrForecast,
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
        na.action = p_fct(default = "na.contiguous", levels = c("na.contiguous", "na.interp", "na.fail"))
      )

      super$initialize(
        id = "fcst.ets",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("Date", "integer", "numeric"),
        properties = c("univariate", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "ETS",
        man = "mlr3forecast::mlr_learners_fcst.ets"
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
      # TODO: is this relefant for ETS?
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }

      invoke(forecast::ets,
        y = stats::ts(task$data(cols = task$target_names)[[1L]]),
        .args = pv
      )
    }
  )
)

#' @include zzz.R
register_learner("fcst.ets", LearnerFcstEts)
