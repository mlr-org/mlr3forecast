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
        distr = p_fct(c("poisson", "nbinom"), default = "poisson", tags = "train")
      )

      super$initialize(
        id = "fcst.tscount",
        param_set = param_set,
        predict_types = "response",
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
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        response = stats::fitted(self$model)[task$row_ids]
        return(insert_named(prediction, list(response = response)))
      }

      newxreg = NULL
      if (task$n_features > 0L) {
        newxreg = as.matrix(task$data(cols = task$feature_names))
      }

      pred = stats::predict(self$model, n.ahead = task$nrow, newxreg = newxreg, level = 0)
      insert_named(prediction, list(response = as.numeric(pred$pred)))
    }
  )
)

#' @include zzz.R
register_learner("fcst.tscount", LearnerFcstTscount)
