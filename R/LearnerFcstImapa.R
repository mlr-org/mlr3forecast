#' @include LearnerFcst.R
#' @title Intermittent MAPA Forecast Learner
#'
#' @name mlr_learners_fcst.imapa
#'
#' @description
#' Intermittent multiple aggregation prediction algorithm (iMAPA).
#' The series is temporally aggregated at several levels, Croston, SBA, or SES is selected and fitted at each level,
#' and the resulting demand rates are combined into a single forecast.
#' Calls [tsintermittent::imapa()] from package \CRANpkg{tsintermittent}.
#'
#' @templateVar id fcst.imapa
#' @template learner
#'
#' @references
#' `r format_bib("petropoulos2015forecast", "kourentzes2014intermittent")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstImapa = R6Class(
  "LearnerFcstImapa",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        w = p_uty(
          default = NULL,
          tags = "train",
          custom_check = crate(function(x) {
            check_numeric(x, lower = 0, upper = 1, any.missing = FALSE, min.len = 1L, max.len = 2L, null.ok = TRUE)
          })
        ),
        minimumAL = p_int(1L, default = 1L, tags = "train"),
        maximumAL = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        comb = p_fct(c("mean", "median"), default = "mean", tags = "train"),
        init.opt = p_lgl(default = TRUE, tags = "train"),
        paral = p_int(0L, 2L, default = 0L, tags = "train"),
        cl = p_uty(default = NULL, tags = "train"),
        na.rm = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.imapa",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "tsintermittent"),
        label = "Intermittent MAPA",
        man = "mlr3forecast::mlr_learners_fcst.imapa"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      y = as.numeric(task$data(cols = task$target_names, ordered = TRUE)[[1L]])
      model = invoke(tsintermittent::imapa, data = y, h = 1L, outplot = 0L, .args = pv)
      private$.set_context(model, task)
    },

    .predict = function(task) {
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        return(insert_named(prediction, list(response = private$.fitted_response(task))))
      }

      response = as.numeric(forecast(self$native_model, h = task$nrow))
      insert_named(prediction, list(response = response))
    }
  )
)

#' @include zzz.R
register_learner("fcst.imapa", LearnerFcstImapa)
