#' @title Time Series Feature Extraction
#' @name mlr_pipeops_fcst.tsfeats
#'
#' @description
#' Computes per-series summary features from the target variable via [tsfeatures::tsfeatures()] and broadcasts them
#' as constant columns to every row of the corresponding series. For an unkeyed task the features are broadcast to
#' every row; for a keyed task each key contributes one feature vector.
#'
#' Features are cached in the state at train time and reused at predict time. Predicting on a key that was not seen
#' during training is an error.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreproc], as well as:
#' * `features` :: `character()`\cr
#'   Function names from the `tsfeatures` namespace that return numeric feature vectors. Default
#'   `c("frequency", "stl_features", "entropy", "acf_features")`.
#' * `scale` :: `logical(1)`\cr
#'   If `TRUE`, scale each series to mean 0 and sd 1 before feature extraction. Default `TRUE`.
#' * `trim` :: `logical(1)`\cr
#'   If `TRUE`, trim values outside `±trim_amount` before feature extraction. Default `FALSE`.
#' * `trim_amount` :: `numeric(1)`\cr
#'   Trimming threshold. Default `0.1`.
#' * `parallel` :: `logical(1)`\cr
#'   If `TRUE`, compute features in parallel via a [future::plan()]. Default `FALSE`.
#' * `multiprocess` :: `function`\cr
#'   Function from the `future` package used when `parallel = TRUE`. Default [future::multisession()].
#' * `na.action` :: `function`\cr
#'   Missing-value handler. Default [stats::na.pass()].
#'
#' @export
#' @examples
#' \dontrun{
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' po = po("fcst.tsfeats", features = c("entropy", "acf_features"))
#' out = po$train(list(task))[[1L]]
#' out$head()
#' }
PipeOpFcstTsfeats = R6Class(
  "PipeOpFcstTsfeats",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.tsfeats"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.tsfeats", param_vals = list()) {
      param_set = ps(
        features = p_uty(
          default = c("frequency", "stl_features", "entropy", "acf_features"),
          tags = "train",
          custom_check = function(x) check_character(x, any.missing = FALSE, min.len = 1L)
        ),
        scale = p_lgl(default = TRUE, tags = "train"),
        trim = p_lgl(default = FALSE, tags = "train"),
        trim_amount = p_dbl(lower = 0, default = 0.1, tags = "train", depends = quote(trim == TRUE)), # nolint
        parallel = p_lgl(default = FALSE, tags = "train"),
        multiprocess = p_uty(
          default = future::multisession,
          tags = "train",
          depends = quote(parallel == TRUE), # nolint
          custom_check = check_function
        ),
        na.action = p_uty(default = stats::na.pass, tags = "train", custom_check = check_function)
      )

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines", "tsfeatures"),
        feature_types = c("numeric", "integer", "Date", "factor"),
        tags = "fcst"
      )
    }
  ),

  private = list(
    .train_task = function(task) {
      target = task$target_names
      key_cols = task$col_roles$key
      freq = freq_to_int(task$freq)

      if (length(key_cols) > 0L) {
        dt = task$data(cols = c(target, key_cols))
        tslist = split(dt[[target]], dt[, key_cols, with = FALSE], drop = TRUE)
        tslist = map(tslist, function(x) stats::ts(x, frequency = freq))
        keys = unique(dt[, key_cols, with = FALSE])
      } else {
        tslist = list(stats::ts(task$data(cols = target)[[1L]], frequency = freq))
        keys = NULL
      }

      feats = setDT(invoke(tsfeatures::tsfeatures, tslist = tslist, .args = self$param_set$get_values(tags = "train")))
      setnames(feats, paste0(target, "_tsf_", names(feats)))

      if (length(key_cols) > 0L) {
        feats = cbind(keys, feats)
      }
      self$state = list(features = feats, key_cols = key_cols)
      private$.broadcast(task, feats, key_cols)
    },

    .predict_task = function(task) {
      feats = self$state$features
      key_cols = self$state$key_cols
      private$.broadcast(task, feats, key_cols)
    },

    .broadcast = function(task, feats, key_cols) {
      feat_cols = setdiff(names(feats), key_cols)
      if (length(key_cols) > 0L) {
        joined = feats[task$data(cols = key_cols), on = key_cols]
        if (anyNA(joined[[feat_cols[1L]]])) {
          error_input("PipeOpFcstTsfeats: some keys were not seen during training.")
        }
        task$select(task$feature_names)$cbind(joined[, feat_cols, with = FALSE])
      } else {
        broadcast = feats[rep(1L, task$nrow)]
        task$select(task$feature_names)$cbind(broadcast)
      }
    }
  )
)

#' @include zzz.R
register_po("fcst.tsfeats", PipeOpFcstTsfeats)
