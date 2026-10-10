#' @include LearnerFcstSetar.R
#' @title SETAR-Tree Forecast Learner
#'
#' @name mlr_learners_fcst.setartree
#'
#' @description
#' SETAR-Tree model, a regression tree whose node splits follow self-exciting threshold autoregressive models,
#' with pooled linear autoregressive models in its leaves.
#' The tree depth is controlled by a statistical linearity test and the error reduction of each split.
#' Multi-step forecasts are produced recursively,
#' and quantiles are derived from normal prediction intervals based on the residual standard deviation of each leaf.
#' In-sample prediction is not supported.
#' Calls [setartree::setartree()] from package \CRANpkg{setartree}.
#'
#' @section Initial parameter values:
#' * `verbose` is initialized to `0L` to suppress the training messages.
#'
#' @templateVar id fcst.setartree
#' @template learner
#'
#' @references
#' `r format_bib("godahewa2023setar")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstSetartree = R6Class(
  "LearnerFcstSetartree",
  inherit = LearnerFcstSetar,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        lag = p_int(2L, default = 10L, tags = "train"),
        depth = p_int(1L, default = 1000L, tags = "train"),
        significance = p_dbl(0, 1, default = 0.05, tags = "train"),
        significance_divider = p_dbl(0, default = 2, tags = "train"),
        error_threshold = p_dbl(0, default = 0.03, tags = "train"),
        stopping_criteria = p_fct(c("lin_test", "error_imp", "both"), default = "both", tags = "train"),
        mean_normalisation = p_lgl(default = FALSE, tags = "train"),
        window_normalisation = p_lgl(default = FALSE, tags = "train"),
        verbose = p_int(0L, 2L, default = 2L, init = 0L, tags = "train")
      )

      super$initialize(
        id = "fcst.setartree",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = "featureless",
        packages = c("mlr3forecast", "setartree"),
        label = "SETAR-Tree",
        man = "mlr3forecast::mlr_learners_fcst.setartree"
      )
    }
  ),

  private = list(
    .fn = "setartree"
  )
)

#' @include zzz.R
register_learner("fcst.setartree", LearnerFcstSetartree)
