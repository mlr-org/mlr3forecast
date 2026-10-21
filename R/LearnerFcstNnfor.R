#' @title Abstract class for nnfor package learners
#' @keywords internal
#' @include LearnerFcstForecast.R
LearnerFcstNnfor = R6Class(
  "LearnerFcstNnfor",
  inherit = LearnerFcstForecast,
  private = list(
    .pkg = "nnfor",

    .train = function(task) {
      context = super$.train(task)
      # nnfor's forecast() needs xreg for the training period plus the horizon, but the fitted model does not keep it
      context$xreg = private$.xreg(task)
      context
    },

    .adjust_predict_args = function(args, is_quantile) {
      xreg = self$model$xreg
      if (!is.null(xreg)) {
        args$xreg = rbind(xreg, args$xreg[, colnames(xreg), drop = FALSE])
      }
      args
    },

    .fitted = function() {
      model = self$native_model
      fitted = as.numeric(stats::fitted(model))
      c(rep.int(NA_real_, length(model$y) - length(fitted)), fitted)
    }
  )
)
