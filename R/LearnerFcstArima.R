#' @title ARIMA Forecast Learner
#'
#' @name mlr_learners_fcst.arima
#'
#' @description
#' Autoregressive Integrated Moving Average Forecast (ARIMA) model.
#' Calls [forecast::Arima()] from package \CRANpkg{forecast}.
#'
#' @templateVar id fcst.arima
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018fpp")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstArima = R6Class(
  "LearnerFcstArima",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        order = p_uty(
          default = c(0L, 0L, 0L),
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 0L, len = 3L))
        ),
        seasonal = p_uty(
          default = c(0L, 0L, 0L),
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 0L, len = 3L))
        ),
        include.mean = p_lgl(default = TRUE, tags = "train"),
        include.drift = p_lgl(default = FALSE, tags = "train"),
        include.constant = p_lgl(default = FALSE, tags = "train"),
        lambda = p_uty(default = NULL, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = "train"),
        method = p_fct(c("CSS-ML", "ML", "CSS"), default = "CSS-ML", tags = "train"),
        # additional arguments to stats::arima
        transform.pars = p_lgl(default = TRUE, tags = "train"),
        SSinit = p_fct(c("Gardner1980", "Rossignol2011"), default = "Gardner1980", tags = "train"),
        optim.method = p_fct(
          c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN", "Brent"),
          default = "BFGS",
          tags = "train"
        ),
        optim.control = p_uty(default = list(), tags = "train", custom_check = check_list),
        kappa = p_dbl(default = 1e6, tags = "train")
      )

      super$initialize(
        id = "fcst.arima",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "ARIMA",
        man = "mlr3forecast::mlr_learners_fcst.arima"
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
      invoke(forecast::Arima, y = as.ts(task), xreg = xreg, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.arima", LearnerFcstArima)
