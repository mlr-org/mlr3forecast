PipeOpLags = R6Class("PipeOpLags",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fda.cor"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcsts.lags", param_vals = list()) {
      param_set = ps(
        lag = p_uty(tags = c("train", "predict"), custom_check = check_integerish)
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines"),
        feature_types = c("numeric", "integer", "Date", "factor") # NOTE: this filters based on features
      )
    }
  ),
  private = list(

    .train_dt = function(dt, levels, target) {
      browser()
    },

    .predict_dt = function(dt, levels) {
      ..NotYetImplemented()
    }
  )
)

#' @include zzz.R
register_po("fcst.lags", PipeOpLags)
