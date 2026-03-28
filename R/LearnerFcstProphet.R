#' @title Prophet Forecast Learner
#'
#' @name mlr_learners_fcst.prophet
#'
#' @description
#' Prophet model.
#' Calls [prophet::prophet()] from package \CRANpkg{prophet}.
#'
#' @templateVar id fcst.prophet
#' @template learner
#'
#' @references
#' `r format_bib("taylor2018forecasting")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstProphet = R6Class(
  "LearnerFcstProphet",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        growth = p_fct(c("linear", "logistic", "flat"), default = "linear", tags = "train"),
        n.changepoints = p_int(0L, default = 25L, tags = "train"),
        changepoint.range = p_dbl(0, 1, default = 0.8, tags = "train"),
        yearly.seasonality = p_uty(default = "auto", tags = "train"),
        weekly.seasonality = p_uty(default = "auto", tags = "train"),
        daily.seasonality = p_uty(default = "auto", tags = "train"),
        seasonality.mode = p_fct(c("additive", "multiplicative"), default = "additive", tags = "train"),
        seasonality.prior.scale = p_dbl(0, default = 10, tags = "train"),
        holidays.prior.scale = p_dbl(0, default = 10, tags = "train"),
        changepoint.prior.scale = p_dbl(0, default = 0.05, tags = "train"),
        mcmc.samples = p_int(0L, default = 0L, tags = "train"),
        interval.width = p_dbl(0, 1, default = 0.8, tags = "train"),
        uncertainty.samples = p_int(0L, default = 1000L, tags = "train")
      )

      super$initialize(
        id = "fcst.prophet",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous"),
        packages = c("mlr3forecast", "prophet"),
        label = "Prophet",
        man = "mlr3forecast::mlr_learners_fcst.prophet"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      order_col = task$col_roles$order
      dt = task$data(cols = c(order_col, task$target_names))
      setnames(dt, c("ds", "y"))

      feature_names = task$feature_names
      if (length(feature_names) > 0L) {
        features = task$data(cols = feature_names)
        dt = cbind(dt, features)
        m = invoke(prophet::prophet, df = NULL, .args = pv)
        for (nm in feature_names) {
          m = prophet::add_regressor(m, nm)
        }
        m = prophet::fit.prophet(m, dt)
      } else {
        m = invoke(prophet::prophet, df = dt, .args = pv)
      }

      m
    },

    .predict = function(task) {
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        insample = stats::predict(self$model)
        response = insample$yhat[task$row_ids]
        return(insert_named(prediction, list(response = response)))
      }

      order_col = task$col_roles$order
      dt = task$data(cols = order_col)
      setnames(dt, "ds")

      feature_names = task$feature_names
      if (length(feature_names) > 0L) {
        features = task$data(cols = feature_names)
        dt = cbind(dt, features)
      }

      pred = stats::predict(self$model, dt)
      insert_named(prediction, list(response = pred$yhat))
    }
  )
)

#' @include zzz.R
register_learner("fcst.prophet", LearnerFcstProphet)
