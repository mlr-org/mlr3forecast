#' @title Standard Theta Method Forecast Learner
#'
#' @name mlr_learners_fcst.stheta
#'
#' @description
#' Standard theta method.
#' Calls [forecTheta::stheta()] from package \CRANpkg{forecTheta}.
#'
#' @templateVar id fcst.stheta
#' @template learner
#'
#' @references
#' `r format_bib("assimakopoulos2000theta")`
#'
#' @export
#' @template seealso_learner
#' @template example
#' @include LearnerFcst.R
LearnerFcstStheta = R6Class(
  "LearnerFcstStheta",
  inherit = LearnerFcst,
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
        )
      )

      super$initialize(
        id = "fcst.stheta",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("logical", "integer", "numeric"),
        properties = "featureless",
        packages = c("mlr3forecast", "forecTheta"),
        label = "Standard Theta Method",
        man = "mlr3forecast::mlr_learners_fcst.stheta"
      )
    }
  ),
  private = list(
    .seasonal = TRUE,

    .train = function(task) {
      super$.train(task)
      pv = private$.train_values()
      model = invoke(forecTheta::stheta, y = private$.as_ts(task), h = 1L, .args = pv)
      context = private$.set_context(model, task)
      context$params = pv
      context
    },

    .predict = function(task) {
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))
      if (!private$.is_newdata(task)) {
        return(insert_named(prediction, list(response = private$.fitted_response(task))))
      }

      model = self$native_model
      pv = self$model$params
      pred = invoke(
        forecTheta::stm,
        y = model$y,
        h = task$nrow,
        level = NULL,
        par_ini = c(model$par[1L] / 2, model$par[2L]),
        estimation = FALSE,
        .args = pv
      )
      insert_named(prediction, list(response = as.numeric(pred$mean)))
    }
  )
)

#' @include zzz.R
register_learner("fcst.stheta", LearnerFcstStheta)
