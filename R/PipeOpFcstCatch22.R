#' @title Time Series Feature Extraction (catch22)
#' @name mlr_pipeops_fcst.catch22
#'
#' @description
#' This `PipeOp` extracts the 22 (or 24) canonical time series characteristics (catch22) from the target variable.
#' For more details, see [Rcatch22::catch22_all()], which is called internally on the ordered target vector.
#'
#' For other time series feature extractors, see [PipeOpFcstTsfeats] and [PipeOpFcstFeasts].
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [mlr3pipelines::PipeOpTaskPreproc], as well as:
#' * `catch24` :: `logical(1)`\cr
#'   If `TRUE`, additionally compute the mean and standard deviation (the catch24 set). Default `FALSE`.
#'
#' @section Naming:
#' The new columns are named `{target}_catch22_{feature}`. If the target was called `"y"` and the feature is
#' `"DN_HistogramMode_5"`, the corresponding new column will be called `"y_catch22_DN_HistogramMode_5"`.
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
        can_subset_cols = FALSE,
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
        keys = task$data(cols = key_cols)
        unseen = unique(keys)[!feats, on = key_cols]
        if (nrow(unseen) > 0L) {
          labels = key_labels(unseen)
          error_input("Key group(s) %s were not seen during training.", str_collapse(labels, quote = "'"))
        }
        joined = feats[keys, on = key_cols]
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
