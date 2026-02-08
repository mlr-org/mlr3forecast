#' @title Auto ARIMA Forecast Learner
#'
#' @name mlr_learners_fcst.auto_arima
#'
#' @description
#' Auto ARIMA model.
#' Calls [forecast::auto.arima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.auto_arima
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018automatic", "wang2006characteristic")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstAutoArima = R6Class(
  "LearnerFcstAutoArima",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        d = p_int(0L, default = NA, special_vals = list(NA), tags = "train"),
        D = p_int(0L, default = NA, special_vals = list(NA), tags = "train"),
        max.p = p_int(0L, default = 5L, tags = "train"),
        max.q = p_int(0L, default = 5L, tags = "train"),
        max.P = p_int(0L, default = 2L, tags = "train"),
        max.Q = p_int(0L, default = 2L, tags = "train"),
        max.order = p_int(0L, default = 5L, tags = "train"),
        max.d = p_int(0L, default = 2L, tags = "train"),
        max.D = p_int(0L, default = 1L, tags = "train"),
        start.p = p_int(0L, default = 2L, tags = "train"),
        start.q = p_int(0L, default = 2L, tags = "train"),
        start.P = p_int(0L, default = 1L, tags = "train"),
        start.Q = p_int(0L, default = 1L, tags = "train"),
        stationary = p_lgl(default = FALSE, tags = "train"),
        seasonal = p_lgl(default = TRUE, tags = "train"),
        ic = p_fct(c("aicc", "aic", "bic"), default = "aicc", tags = "train"),
        stepwise = p_lgl(default = TRUE, tags = "train"),
        nmodels = p_int(0L, default = 94L, tags = "train"),
        trace = p_lgl(default = FALSE, tags = "train"),
        approximation = p_uty(tags = "train"),
        method = p_uty(default = NULL, tags = "train"),
        truncate = p_uty(default = NULL, tags = "train"),
        test = p_fct(c("kpss", "adf", "pp"), default = "kpss", tags = "train"),
        test.args = p_uty(default = list(), tags = "train", custom_check = check_list),
        seasonal.test = p_fct(c("seas", "ocsb", "hegy", "ch"), default = "seas", tags = "train"),
        seasonal.test.args = p_uty(default = list(), tags = "train", custom_check = check_list),
        allowdrift = p_lgl(default = TRUE, tags = "train"),
        allowmean = p_lgl(default = TRUE, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict")),
        parallel = p_lgl(default = FALSE, tags = "train"),
        num.cores = p_int(1L, default = 2L, special_vals = list(NULL), tags = "train"),
        # additional arguments to forecast::Arima
        include.mean = p_lgl(default = TRUE, tags = "train"),
        include.drift = p_lgl(default = FALSE, tags = "train"),
        include.constant = p_lgl(default = FALSE, tags = "train"),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        bootstrap = p_lgl(default = FALSE, tags = "predict"),
        npaths = p_int(1L, default = 5000L, tags = "predict"),
        # additional arguments to stats::arima
        transform.pars = p_lgl(default = TRUE, tags = "train"),
        fixed = p_uty(default = NULL, special_vals = list(NULL), tags = "train", custom_check = check_numeric),
        init = p_uty(default = NULL, special_vals = list(NULL), tags = "train", custom_check = check_numeric),
        SSinit = p_fct(c("Gardner1980", "Rossignol2011"), default = "Gardner1980", tags = "train"),
        n.cond = p_int(1L, tags = "train"),
        optim.method = p_fct(
          c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN", "Brent"),
          default = "BFGS",
          tags = "train"
        ),
        optim.control = p_uty(default = list(), tags = "train", custom_check = check_list),
        kappa = p_dbl(default = 1e6, tags = "train")
      )

      super$initialize(
        id = "fcst.auto_arima",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Auto ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.auto_arima"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")

      xreg = NULL
      if (task$n_features > 0L) {
        xreg = as.matrix(task$data(cols = task$feature_names))
      }
      invoke(forecast::auto.arima, y = as.ts(task), xreg = xreg, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.auto_arima", LearnerFcstAutoArima)
