#' @title Autoregressive Forecast Learner
#'
#' @name mlr_learners_fcst.ar
#'
#' @description
#' Univariate autoregressive model with the order selected by AIC.
#' Calls [stats::ar()] from package \pkg{stats} and forecasts via [forecast::forecast()].
#'
#' @templateVar id fcst.ar
#' @template learner
#'
#' @references
#' `r format_bib("brockwell1991")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstAr = R6Class(
  "LearnerFcstAr",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        aic = p_lgl(default = TRUE, tags = "train"),
        order.max = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        method = p_fct(c("yule-walker", "burg", "ols", "mle", "yw"), default = "yule-walker", tags = "train"),
        demean = p_lgl(default = TRUE, tags = "train"),
        var.method = p_int(1L, 2L, default = 1L, tags = "train", depends = quote(method == "burg")),
        intercept = p_lgl(tags = "train", depends = quote(method == "ols")),
        # forecast arguments
        simulate = p_lgl(default = FALSE, tags = "predict"),
        bootstrap = p_lgl(default = FALSE, tags = "predict"),
        innov = p_uty(
          default = NULL,
          tags = "predict",
          custom_check = crate(function(x) check_numeric(x, null.ok = TRUE))
        ),
        npaths = p_int(1L, default = 5000L, tags = "predict"),
        lambda = p_uty(default = NULL, tags = "predict"),
        biasadj = p_lgl(default = FALSE, tags = "predict")
      )

      super$initialize(
        id = "fcst.ar",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = "featureless",
        packages = c("mlr3forecast", "forecast"),
        label = "Autoregressive",
        man = "mlr3forecast::mlr_learners_fcst.ar"
      )
    }
  ),

  private = list(
    .pkg = "stats",
    .fn = "ar",
    .y_arg = "x",

    # stats::ar() drops the series, which forecast::getResponse.ar() needs to predict
    .tidy_model = function(model, task) {
      model$x = as.ts(task)
      super$.tidy_model(model, task)
    }
  )
)

#' @include zzz.R
register_learner("fcst.ar", LearnerFcstAr)
