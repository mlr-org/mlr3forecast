#' @include LearnerFcstSmooth.R
#' @title PTS Forecast Learner
#'
#' @name mlr_learners_fcst.pts
#'
#' @description
#' Power / Trend / Seasonal (PTS) structural state-space model.
#' Calls [muse::pts()] from package \CRANpkg{muse}.
#'
#' @template section_custom_period
#'
#' @templateVar id fcst.pts
#' @template learner
#'
#' @references
#' `r format_bib("harvey1989forecasting", "durbin2012time", "proietti2000comparing", "sbrana2023rwdar")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstPts = R6Class(
  "LearnerFcstPts",
  inherit = LearnerFcstSmooth,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        model = p_uty(
          default = "ZZZ",
          tags = "train",
          custom_check = crate(function(x) check_string(x, min.chars = 3L))
        ),
        lags = p_uty(tags = "train", custom_check = check_numeric),
        orders = p_uty(
          default = list(ar = 0, ma = 0, select = FALSE),
          tags = "train",
          custom_check = crate(function(x) check_list(x) %check||% check_integerish(x, lower = 0L, max.len = 2L))
        ),
        regressors = p_fct("use", default = "use", tags = "train"),
        outliers = p_fct(c("ignore", "use"), default = "ignore", tags = "train"),
        level = p_dbl(0, 1, default = 0.99, tags = "train"),
        ic = p_fct(c("AICc", "BICc", "BIC", "AIC"), default = "AICc", tags = "train"),
        lambda_estim = p_fct(c("likelihood", "guerrero", "decomp-guerrero"), default = "likelihood", tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train"),
        verbose = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.pts",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous"),
        packages = c("mlr3forecast", "muse"),
        label = "PTS",
        man = "mlr3forecast::mlr_learners_fcst.pts"
      )
    }
  ),

  private = list(
    .pkg = "muse",
    .min_level = 1e-8,
    .fn = "pts",
    .y_arg = "data"
  )
)

#' @include zzz.R
register_learner("fcst.pts", LearnerFcstPts)
