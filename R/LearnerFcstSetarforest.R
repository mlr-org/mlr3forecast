#' @include LearnerFcstSetar.R
#' @title SETAR-Forest Forecast Learner
#'
#' @name mlr_learners_fcst.setarforest
#'
#' @description
#' SETAR-Forest model, a bagged ensemble of SETAR-Trees whose forecasts are averaged.
#' Each tree is trained on a random subset of the lagged training instances,
#' and by default with randomly drawn significance, significance divider, and error threshold.
#' Multi-step forecasts are produced recursively,
#' and quantiles are derived from normal prediction intervals based on the residual standard deviations of the leaves.
#' In-sample prediction is not supported.
#' Calls [setartree::setarforest()] from package \CRANpkg{setartree}.
#'
#' The forest is deterministic, since [setartree::setarforest()] seeds the training of each tree with its index.
#' The global random number generator state is restored after training.
#'
#' @section Initial parameter values:
#' * `verbose` is initialized to `0L` to suppress the training messages.
#' * `num_cores` is initialized to `1L` to train the trees sequentially instead of on all available cores.
#'   It is tagged `"threads"`, so [mlr3::set_threads()] can set it.
#'
#' @templateVar id fcst.setarforest
#' @template learner
#'
#' @references
#' `r format_bib("godahewa2023setar")`
#'
#' @export
#' @template seealso_learner
#' @template example_slow
LearnerFcstSetarforest = R6Class(
  "LearnerFcstSetarforest",
  inherit = LearnerFcstSetar,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        lag = p_int(2L, default = 10L, tags = "train"),
        bagging_fraction = p_dbl(0, 1, default = 0.8, tags = "train"),
        bagging_freq = p_int(1L, default = 10L, tags = "train"),
        random_tree_significance = p_lgl(default = TRUE, tags = "train"),
        random_tree_significance_divider = p_lgl(default = TRUE, tags = "train"),
        random_tree_error_threshold = p_lgl(default = TRUE, tags = "train"),
        depth = p_int(1L, default = 1000L, tags = "train"),
        significance = p_dbl(0, 1, default = 0.05, tags = "train"),
        significance_divider = p_dbl(0, default = 2, tags = "train"),
        error_threshold = p_dbl(0, default = 0.03, tags = "train"),
        stopping_criteria = p_fct(c("lin_test", "error_imp", "both"), default = "both", tags = "train"),
        mean_normalisation = p_lgl(default = FALSE, tags = "train"),
        window_normalisation = p_lgl(default = FALSE, tags = "train"),
        verbose = p_int(0L, 2L, default = 2L, init = 0L, tags = "train"),
        num_cores = p_int(
          lower = 1L,
          default = NULL,
          special_vals = list(NULL),
          init = 1L,
          tags = c("train", "threads")
        )
      )

      super$initialize(
        id = "fcst.setarforest",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = "featureless",
        packages = c("mlr3forecast", "setartree"),
        label = "SETAR-Forest",
        man = "mlr3forecast::mlr_learners_fcst.setarforest"
      )
    }
  ),

  private = list(
    .fn = "setarforest",

    .fit = function(y, pv) {
      # setarforest() calls set.seed() for every tree
      with_preserved_seed(super$.fit(y, pv))
    }
  )
)

#' @include zzz.R
register_learner("fcst.setarforest", LearnerFcstSetarforest)
