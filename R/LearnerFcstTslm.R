#' @include LearnerFcstForecast.R
#' @title Time Series Linear Model Forecast Learner
#'
#' @name mlr_learners_fcst.tslm
#'
#' @description
#' Time series linear model.
#' Calls [forecast::tslm()] from package \CRANpkg{forecast}.
#'
#' If `formula` is not set, the model is fit with the `trend` term of [forecast::tslm()] plus all features.
#' The `season` term is included when the seasonal period is greater than one.
#' Since [forecast::tslm()] reserves the names `trend` and `season` for these terms,
#' a task with a target or feature of either name requires `formula`.
#'
#' @templateVar id fcst.tslm
#' @template learner
#'
#' @references
#' `r format_bib("hyndman2018fpp")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstTslm = R6Class(
  "LearnerFcstTslm",
  inherit = LearnerFcstForecast,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        formula = p_uty(tags = "train", custom_check = check_formula),
        lambda = p_uty(default = NULL, tags = "train"),
        biasadj = p_lgl(default = FALSE, tags = c("train", "predict"))
      )

      super$initialize(
        id = "fcst.tslm",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = c("logical", "integer", "numeric"),
        properties = c("featureless", "exogenous", "missings"),
        packages = c("mlr3forecast", "forecast"),
        label = "Time Series Linear Model",
        man = "mlr3forecast::mlr_learners_fcst.tslm"
      )
    }
  ),

  private = list(
    .newdata_arg = "newdata",
    .newdata_as_matrix = FALSE,

    .fit = function(task, pv) {
      y = private$.as_ts(task)
      if (is.null(pv$formula)) {
        # tslm() takes a column named trend or season as that term instead of building its own
        reserved = intersect(c(task$target_names, task$feature_names), c("trend", "season"))
        if (length(reserved) > 0L) {
          error_input(
            paste0(
              "%s learner reserves the names 'trend' and 'season' for its built-in terms, ",
              "but Task '%s' has column(s) %s. Rename them or set `formula`."
            ),
            self$id,
            task$id,
            str_collapse(reserved, quote = "'")
          )
        }
        rhs = c("trend", if (stats::frequency(y) > 1) "season", task$feature_names)
        pv$formula = task$formula(rhs = rhs)
      }
      if (private$.has_exogenous(task)) {
        mat = cbind(matrix(y, ncol = 1L), as_numeric_matrix(task$data(cols = task$feature_names, ordered = TRUE)))
        colnames(mat)[1L] = task$target_names
      } else {
        mat = matrix(y, ncol = 1L, dimnames = list(NULL, task$target_names))
      }
      data = stats::ts(mat, start = stats::start(y), frequency = stats::frequency(y))
      invoke(forecast::tslm, data = data, .args = pv)
    }
  )
)

#' @include zzz.R
register_learner("fcst.tslm", LearnerFcstTslm)
