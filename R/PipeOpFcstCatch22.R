#' @title Time Series Feature Extraction (catch22)
#' @name mlr_pipeops_fcst.catch22
#'
#' @description
#' Computes the 22 (or 24) canonical time-series characteristics of the target variable via
#' [Rcatch22::catch22_all()], and broadcasts them as constant columns to every row of the corresponding
#' series. For an unkeyed task the features are broadcast to every row; for a keyed task each key
#' contributes one feature vector.
#'
#' The catch22 set is a low-redundancy subset of the \pkg{hctsa} features selected for time-series
#' classification performance and is computed in C, making it considerably faster than [PipeOpFcstTsfeats]
#' and [PipeOpFcstFeasts]. The features are computed on the ordered target vector and are agnostic to the
#' seasonal period, so unlike the other two extractors they contain no explicit seasonal/trend features.
#'
#' Features are cached in the state at train time and reused at predict time. Predicting on a key that was
#' not seen during training is an error.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreproc], as well as:
#' * `catch24` :: `logical(1)`\cr
#'   If `TRUE`, additionally compute the mean and standard deviation (the catch24 set). Default `FALSE`.
#'
#' @export
#' @examplesIf requireNamespace("Rcatch22", quietly = TRUE)
#' library(mlr3pipelines)
#' task = tsk("airpassengers")
#' po = po("fcst.catch22")
#' out = po$train(list(task))[[1L]]
#' out$head()
PipeOpFcstCatch22 = R6Class(
  "PipeOpFcstCatch22",
  inherit = PipeOpTaskPreproc,
  public = list(
    #' @description Initializes a new instance of this Class.
    #' @param id (`character(1)`)\cr
    #'   Identifier of resulting object, default `"fcst.catch22"`.
    #' @param param_vals (named `list()`)\cr
    #'   List of hyperparameter settings, overwriting the hyperparameter settings that would
    #'   otherwise be set during construction. Default `list()`.
    initialize = function(id = "fcst.catch22", param_vals = list()) {
      param_set = ps(catch24 = p_lgl(default = FALSE, tags = "train"))

      super$initialize(
        id = id,
        param_set = param_set,
        param_vals = param_vals,
        packages = c("mlr3forecast", "mlr3pipelines", "Rcatch22"),
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
      catch24 = self$param_set$get_values(tags = "train")$catch24 %??% FALSE

      dt = task$data(cols = c(target, order_cols, key_cols))
      setorderv(dt, c(key_cols, order_cols))
      feats = if (length(key_cols) > 0L) {
        dt[, private$.catch22(get(target), catch24), by = key_cols]
      } else {
        setDT(private$.catch22(dt[[target]], catch24))
      }
      feat_cols = setdiff(names(feats), key_cols)
      setnames(feats, feat_cols, paste0(target, "_catch22_", feat_cols))

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
          error_input("PipeOpFcstCatch22: some keys were not seen during training.")
        }
        task$select(task$feature_names)$cbind(joined[, feat_cols, with = FALSE])
      } else {
        task$select(task$feature_names)$cbind(feats[rep(1L, task$nrow)])
      }
    },

    .catch22 = function(x, catch24) {
      # muffle Rcatch22's once-per-session notice about CO_f1ecac's return type
      res = withCallingHandlers(
        invoke(Rcatch22::catch22_all, as.numeric(x), catch24 = catch24),
        warning = function(w) {
          if (grepl("CO_f1ecac", conditionMessage(w), fixed = TRUE)) {
            invokeRestart("muffleWarning")
          }
        }
      )
      as.list(set_names(res$values, res$names))
    }
  )
)

#' @include zzz.R
register_po("fcst.catch22", PipeOpFcstCatch22)
