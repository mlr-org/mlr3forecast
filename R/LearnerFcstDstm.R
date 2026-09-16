#' @title Dynamic Standard Theta Model Forecast Learner
#'
#' @name mlr_learners_fcst.dstm
#'
#' @description
#' Dynamic standard theta model.
#' Calls [forecTheta::dstm()] from package \CRANpkg{forecTheta}.
#'
#' @templateVar id fcst.dstm
#' @template learner
#'
#' @references
#' `r format_bib("fiorucci2016models")`
#'
#' @export
#' @template seealso_learner
#' @template example
#' @include LearnerFcstForecTheta.R
LearnerFcstDstm = R6Class(
  "LearnerFcstDstm",
  inherit = LearnerFcstForecTheta,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        s_type = p_fct(c("multiplicative", "additive", "stl"), default = "multiplicative", tags = "train"),
        s_test = p_uty(
          default = "default",
          tags = "train",
          custom_check = crate(function(x) check_flag(x) %check||% check_choice(x, c("default", "unit_root")))
        ),
        lambda = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) {
            if (is.null(x) || test_number(x) || identical(x, "auto")) TRUE else "Must be NULL, a number, or 'auto'."
          })
        ),
        par_ini = p_uty(
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE, min.len = 2L))
        ),
        lower = p_uty(
          default = c(-1e10, 0.1),
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE, min.len = 2L))
        ),
        upper = p_uty(
          default = c(1e10, 0.99),
          tags = "train",
          custom_check = crate(function(x) check_numeric(x, finite = TRUE, any.missing = FALSE, min.len = 2L))
        ),
        opt.method = p_fct(c("Nelder-Mead", "L-BFGS-B", "SANN"), default = "Nelder-Mead", tags = "train")
      )

      super$initialize(
        id = "fcst.dstm",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = "featureless",
        packages = c("mlr3forecast", "forecTheta"),
        label = "Dynamic Standard Theta Model",
        man = "mlr3forecast::mlr_learners_fcst.dstm"
      )
    }
  ),
  private = list(
    .fn = "dstm"
  )
)

#' @include zzz.R
register_learner("fcst.dstm", LearnerFcstDstm)
