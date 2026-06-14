#' @title Time Series Feature Extraction (feasts)
#' @name mlr_pipeops_fcst.feasts
#'
#' @description
#' Computes per-series summary features from the target variable via [fabletools::features()] with feature
#' functions from the \CRANpkg{feasts} package, and broadcasts them as constant columns to every row of the
#' corresponding series. For an unkeyed task the features are broadcast to every row; for a keyed task each key
#' contributes one feature vector.
#'
#' This is the \CRANpkg{feasts} (tidyverts) counterpart of [PipeOpFcstTsfeats], which uses the
#' \CRANpkg{tsfeatures} package. The order column is mapped to an appropriate \CRANpkg{tsibble} index
#' (`yearmonth`/`yearquarter`/`yearweek` for the respective frequencies, otherwise used as-is) so that the
#' seasonal period is inferred correctly.
#'
#' Features are cached in the state at train time and reused at predict time. Predicting on a key that was not
#' seen during training is an error.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreproc], as well as:
#' * `features` :: `list()`\cr
#'   A list of \CRANpkg{feasts} feature functions (e.g. [feasts::feat_acf], [feasts::feat_stl]) or a
#'   [fabletools::feature_set()]. Default `list(feasts::feat_acf, feasts::feat_stl)`.
#'
#' @export
#' @examplesIf requireNamespace("feasts", quietly = TRUE) && requireNamespace("fabletools", quietly = TRUE)
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' po = po("fcst.feasts", features = list(feasts::feat_acf))
#' out = po$train(list(task))[[1L]]
#' out$head()
#'
#' # select features by tag via fabletools::feature_set() (requires feasts to be attached so its
#' # feature registry is populated)
#' library(feasts)
#' po = po("fcst.feasts", features = fabletools::feature_set(pkgs = "feasts", tags = "autocorrelation"))
#' po$train(list(task))[[1L]]$head()
PipeOpFcstFeasts = R6Class(
  "PipeOpFcstFeasts",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.feasts"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.feasts", param_vals = list()) {
      param_set = ps(
        features = p_uty(tags = "train", custom_check = crate(function(x) check_list(x, min.len = 1L)))
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines", "feasts", "fabletools", "tsibble", "tidyselect"),
        feature_types = c("numeric", "integer", "Date", "factor"),
        tags = "fcst"
      )
    }
  ),

  private = list(
    .train_task = function(task) {
      target = task$target_names
      order_cols = task$col_roles$order
      key_cols = task$col_roles$key

      dt = task$data(cols = c(target, order_cols, key_cols))
      setnames(dt, target, ".value")
      set(dt, j = ".idx", value = to_tsibble_index(dt[[order_cols]], task$freq))
      cols = c(".value", ".idx", key_cols)
      tsbl = if (length(key_cols) > 0L) {
        tsibble::build_tsibble(dt[, cols, with = FALSE], key = tidyselect::all_of(key_cols), index = .idx)
      } else {
        tsibble::build_tsibble(dt[, cols, with = FALSE], index = .idx)
      }
      features = self$param_set$get_values(tags = "train")$features %??% list(feasts::feat_acf, feasts::feat_stl)
      feats = setDT(invoke(fabletools::features, tsbl, .value, features = features))
      feat_cols = setdiff(names(feats), key_cols)
      setnames(feats, feat_cols, paste0(target, "_feasts_", feat_cols))

      self$state = list(features = feats, key_cols = key_cols)
      feat_cols = setdiff(names(feats), key_cols)
      if (length(key_cols) > 0L) {
        joined = feats[task$data(cols = key_cols), on = key_cols]
        task$select(task$feature_names)$cbind(joined[, feat_cols, with = FALSE])
      } else {
        task$select(task$feature_names)$cbind(feats[rep(1L, task$nrow)])
      }
    },

    .predict_task = function(task) {
      feats = self$state$features
      key_cols = self$state$key_cols
      feat_cols = setdiff(names(feats), key_cols)
      if (length(key_cols) > 0L) {
        joined = feats[task$data(cols = key_cols), on = key_cols]
        if (anyMissing(joined[[feat_cols[1L]]])) {
          error_input("PipeOpFcstFeasts: some keys were not seen during training.")
        }
        task$select(task$feature_names)$cbind(joined[, feat_cols, with = FALSE])
      } else {
        task$select(task$feature_names)$cbind(feats[rep(1L, task$nrow)])
      }
    }
  )
)

#' @include zzz.R
register_po("fcst.feasts", PipeOpFcstFeasts)
