#' @include LearnerFcst.R
#' @title TSB Forecast Learner
#'
#' @name mlr_learners_fcst.tsb
#'
#' @description
#' Teunter-Syntetos-Babai (TSB) method for intermittent demand.
#' Like Croston's method, it smooths the size of non-zero demands separately,
#' but it smooths the probability of a demand occurring in each period instead of the interval between demands.
#' The probability is updated in every period, so the forecast decays towards zero for items that stop selling.
#' The smoothing parameters and initial values are optimized unless set.
#' The multistep costs `"msce"` and `"mace"` are not offered for `cost`, as the forecast horizon is not known at
#' training time.
#' Calls [tsintermittent::tsb()] from package \CRANpkg{tsintermittent}.
#'
#' @templateVar id fcst.tsb
#' @template learner
#'
#' @references
#' `r format_bib("teunter2011intermittent", "kourentzes2014intermittent")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstTsb = R6Class(
  "LearnerFcstTsb",
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
            check_numeric(x, lower = 0, upper = 1, any.missing = FALSE, len = 2L, null.ok = TRUE)
          })
        ),
        init = p_uty(
          default = "mean",
          tags = "train",
          custom_check = crate(function(x) {
            check_choice(x, c("mean", "naive")) %check||% check_numeric(x, any.missing = FALSE, len = 2L)
          })
        ),
        cost = p_fct(c("mar", "msr", "mae", "mse"), default = "mar", tags = "train"),
        init.opt = p_lgl(default = TRUE, tags = "train"),
        na.rm = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "fcst.tsb",
        param_set = param_set,
        predict_types = "response",
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = c("featureless", "missings"),
        packages = c("mlr3forecast", "tsintermittent"),
        label = "TSB",
        man = "mlr3forecast::mlr_learners_fcst.tsb"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      y = as.numeric(task$data(cols = task$target_names, ordered = TRUE)[[1L]])
      model = invoke(tsintermittent::tsb, data = y, h = 1L, outplot = FALSE, .args = pv)
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
register_learner("fcst.tsb", LearnerFcstTsb)
