#' @include LearnerFcstForecast.R
#' @title Local and Global Trend Forecast Learner
#'
#' @name mlr_learners_fcst.rlgt
#'
#' @description
#' Bayesian exponential smoothing with a nonlinear global trend (LGT/SGT), Student-t errors, and optional
#' heteroscedasticity, fitted via MCMC. The seasonal period is taken from `period`.
#' Calls [Rlgt::rlgt()] from package \CRANpkg{Rlgt}.
#'
#' With `method = "Gibbs"`, a `seasonality` above 1 overrides `period`.
#'
#' @section Initial parameter values:
#' * `method`: Set to `"Gibbs"`, the upstream default, so that `seasonality` and `homoscedastic` can be set without
#'   setting `method` first.
#'
#' @templateVar id fcst.rlgt
#' @template learner
#'
#' @references
#' `r format_bib("smyl2025rlgt")`
#'
#' @export
#' @template seealso_learner
#' @template example_slow
LearnerFcstRlgt = R6Class(
  "LearnerFcstRlgt",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        seasonality = p_int(1L, default = 1L, tags = "train", depends = quote(method == "Gibbs")),
        seasonality2 = p_int(1L, default = 1L, tags = "train", depends = quote(method == "Stan")),
        seasonality.type = p_fct(
          c("multiplicative", "generalized"),
          default = "multiplicative",
          tags = "train",
          depends = quote(method == "Stan")
        ),
        error.size.method = p_fct(
          c("std", "innov"),
          default = "std",
          tags = "train",
          depends = quote(method == "Stan")
        ),
        level.method = p_fct(
          c("HW", "seasAvg", "HW_sAvg"),
          default = "HW",
          tags = "train",
          depends = quote(method == "Stan")
        ),
        method = p_fct(c("Gibbs", "Stan"), tags = "train", init = "Gibbs"),
        homoscedastic = p_lgl(default = FALSE, tags = "train", depends = quote(method == "Gibbs")),
        control = p_uty(tags = "train", custom_check = check_list),
        verbose = p_lgl(default = FALSE, tags = "train", depends = quote(method == "Stan")),
        NUM_OF_TRIALS = p_int(1L, default = 2000L, tags = "predict", depends = quote(method == "Stan"))
      )

      super$initialize(
        id = "fcst.rlgt",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous"),
        packages = c("mlr3forecast", "Rlgt"),
        label = "Local and Global Trend",
        man = "mlr3forecast::mlr_learners_fcst.rlgt"
      )
    }
  ),

  private = list(
    .pkg = "Rlgt",
    .fn = "rlgt",

    .fit = function(task, pv) {
      method = pv$method %??% "Gibbs"
      if (private$.has_exogenous(task) && method != "Stan") {
        error_config(
          "`fcst.rlgt` supports exogenous features only with `method = \"Stan\"` (current method: \"%s\").",
          method
        )
      }
      super$.fit(task, pv)
    },

    .fitted = function() {
      error_config("In-sample prediction is not supported for %s.", self$id)
    },

    # Rlgt expects levels in percent, unlike forecast
    .adjust_level = function(level) {
      # Rlgt special-cases a lone level 50 and crashes; pad it so a 2-column
      # interval matrix comes back. the extra column is ignored downstream
      if (length(level) == 1L && level == 50) c(50, 80) else level
    },

    .postprocess = function(pred) {
      h = length(pred$mean)
      if (!is.null(pred$lower) && nrow(pred$lower) != h) {
        pred$lower = t(pred$lower)
        pred$upper = t(pred$upper)
      }
      pred
    }
  )
)

#' @include zzz.R
register_learner("fcst.rlgt", LearnerFcstRlgt)
