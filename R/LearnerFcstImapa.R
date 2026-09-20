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
#' The wrapped function estimates and forecasts in one call, so prediction re-runs it on the training series with the
#' fitted `model.fit` object and the requested horizon.
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
        na.rm = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.imapa",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = "featureless",
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
      # imapa() drops the forecast matrix to a vector for h = 1 and errors, so fit with a two-step placeholder
      model = invoke(tsintermittent::imapa, data = y, h = 2L, outplot = 0L, .args = pv)
      # the re-run at predict time needs the training series alongside the fitted parameters
      model$data = y
      private$.set_context(model, task)
    },

    .fitted = function() {
      private$.combine(self$native_model, self$native_model$frc.in)
    },

    # imapa() returns the combined demand rate as a vector when several aggregation levels are in use, but the
    # full level-by-horizon matrix, including NA rows for unused levels, when only one level is usable
    .combine = function(model, frc) {
      if (!is.matrix(frc)) {
        return(as.numeric(frc))
      }
      frc = frc[model$summary[6L, ] == 1, , drop = FALSE]
      comb = self$param_set$values$comb %??% "mean"
      as.numeric(if (comb == "median") apply(frc, 2L, stats::median) else colMeans(frc))
    },

    .predict = function(task) {
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        return(insert_named(prediction, list(response = private$.fitted_response(task))))
      }

      # model.fit fixes the per-level models and parameters; the combination settings must be passed again
      pv = self$param_set$get_values(tags = "train")
      model = self$native_model
      pred = invoke(
        tsintermittent::imapa,
        data = model$data,
        h = max(task$nrow, 2L), # same h = 1 limitation as in train; the forecast is flat, so trimming is exact
        model.fit = model$model.fit,
        outplot = 0L,
        .args = pv
      )
      insert_named(prediction, list(response = private$.combine(pred, pred$frc.out)[seq_len(task$nrow)]))
    }
  )
)

#' @include zzz.R
register_learner("fcst.imapa", LearnerFcstImapa)
