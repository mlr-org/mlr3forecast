#' @title ARFIMA Forecast Learner
#'
#' @name mlr_learners_fcst.arfima
#'
#' @description
#' ARFIMA model.
#' Calls [forecast::arfima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.arfima
#' @template learner
#'
#' @references
#' `r format_bib("haslett1989space", "hyndman2008automatic")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstArfima = R6Class(
  "LearnerFcstArfima",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        drange = p_uty(
          default = c(0, 0.5),
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, len = 2L))
        ),
        estim = p_fct(default = "mle", levels = c("mle", "ls"), tags = "train"),
        lambda = p_uty(default = NULL, tags = c("train", "predict")),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict")),
        simulate = p_lgl(default = FALSE, tags = "predict"),
        bootstrap = p_lgl(default = FALSE, tags = "predict"),
        npaths = p_int(1L, default = 5000L, tags = "predict"),
        # additional arguments to forecast::auto.arima; arfima() hardcodes
        # max.P = 0, max.Q = 0, stationary = TRUE (forcing d = D = 0) and allowmean = FALSE,
        # so differencing, seasonal, drift, and mean parameters are not available
        max.p = p_int(0L, default = 5L, tags = "train"),
        max.q = p_int(0L, default = 5L, tags = "train"),
        max.order = p_int(0L, default = 5L, tags = "train"),
        start.p = p_int(0L, default = 2L, tags = "train"),
        start.q = p_int(0L, default = 2L, tags = "train"),
        ic = p_fct(c("aicc", "aic", "bic"), default = "aicc", tags = "train"),
        stepwise = p_lgl(default = TRUE, tags = "train"),
        nmodels = p_int(0L, default = 94L, tags = "train"),
        trace = p_lgl(default = FALSE, tags = "train"),
        approximation = p_lgl(tags = "train"),
        method = p_fct(c("CSS-ML", "ML", "CSS"), default = NULL, special_vals = list(NULL), tags = "train"),
        truncate = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        parallel = p_lgl(default = FALSE, tags = "train"),
        num.cores = p_int(1L, default = 2L, special_vals = list(NULL), tags = "train", depends = quote(parallel == TRUE)),
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
        id = "fcst.arfima",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        # not "exogenous": arfima() accepts xreg at train, but forecast.fracdiff() has no
        # xreg argument, so future regressors would be silently ignored at predict
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "ARFIMA",
        man = "mlr3forecast::mlr_learners_fcst.arfima"
      )
    }
  ),

  private = list(
    .fn = "arfima"
  )
)

#' @include zzz.R
register_learner("fcst.arfima", LearnerFcstArfima)
