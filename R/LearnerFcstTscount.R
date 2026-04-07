#' @title Count Time Series Forecast Learner
#'
#' @name mlr_learners_fcst.tscount
#'
#' @description
#' Generalized linear model for count time series (INGARCH).
#' Calls [tscount::tsglm()] from package \CRANpkg{tscount}.
#'
#' @templateVar id fcst.tscount
#' @template learner
#'
#' @references
#' `r format_bib("liboschik2017tscount")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstTscount = R6Class(
  "LearnerFcstTscount",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        past_obs = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 1L, null.ok = TRUE))
        ),
        past_mean = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 1L, null.ok = TRUE))
        ),
        external = p_uty(
          default = FALSE,
          tags = "train",
          custom_check = crate(function(x) check_logical(x))
        ),
        link = p_fct(c("identity", "log"), default = "identity", tags = "train"),
        distr = p_fct(c("poisson", "nbinom"), default = "poisson", tags = "train"),
        B = p_int(10L, default = 1000L, tags = "predict")
      )

      super$initialize(
        id = "fcst.tscount",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous"),
        packages = c("mlr3forecast", "tscount"),
        label = "Count Time Series",
        man = "mlr3forecast::mlr_learners_fcst.tscount"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      model_args = list()
      if (!is.null(pv$past_obs)) {
        model_args$past_obs = pv$past_obs
        pv$past_obs = NULL
      }
      if (!is.null(pv$past_mean)) {
        model_args$past_mean = pv$past_mean
        pv$past_mean = NULL
      }
      if (!is.null(pv$external)) {
        model_args$external = pv$external
        pv$external = NULL
      }

      xreg = NULL
      if (task$n_features > 0L) {
        xreg = as.matrix(task$data(cols = task$feature_names))
      }

      invoke(
        tscount::tsglm,
        ts = as.integer(task$data(cols = task$target_names)[[1L]]),
        model = model_args,
        xreg = xreg,
        .args = pv
      )
    },

    .predict = function(task) {
      is_quantile = self$predict_type == "quantiles"
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          error_config("Quantile prediction not supported for in-sample prediction.")
        }
        response = stats::fitted(self$model)[task$row_ids]
        return(insert_named(prediction, list(response = response)))
      }

      newxreg = NULL
      if (task$n_features > 0L) {
        newxreg = as.matrix(task$data(cols = task$feature_names))
      }

      pv = self$param_set$get_values(tags = "predict")
      n_ahead = task$nrow

      pred = stats::predict(self$model, n.ahead = n_ahead, newxreg = newxreg, level = 0)
      mu = as.numeric(pred$pred)

      if (!is_quantile) {
        return(insert_named(prediction, list(response = mu)))
      }

      probs = private$.quantiles
      if (n_ahead == 1L) {
        quantiles = if (self$model$distr == "poisson") {
          vapply(probs, function(p) qpois(p, lambda = mu), numeric(1L))
        } else {
          vapply(probs, function(p) qnbinom(p, size = self$model$distrcoefs, mu = mu), numeric(1L))
        }
        quantiles = matrix(quantiles, nrow = 1L)
      } else {
        B = pv$B %??% 1000L
        futureobs = replicate(B, {
          tscount::tsglm.sim(n = n_ahead, fit = self$model, xreg = newxreg, n_start = 0L)$ts
        })
        quantiles = vapply(probs, function(p) apply(futureobs, 1L, quantile, probs = p, type = 1L), numeric(n_ahead))
      }
      setattr(quantiles, "probs", probs)
      setattr(quantiles, "response", private$.quantile_response)
      insert_named(prediction, list(quantiles = quantiles))
    }
  )
)

#' @include zzz.R
register_learner("fcst.tscount", LearnerFcstTscount)
