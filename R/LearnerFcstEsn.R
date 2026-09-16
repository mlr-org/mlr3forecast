#' @title Echo state network forecast learner
#'
#' @name mlr_learners_fcst.esn
#'
#' @description
#' Fits a univariate echo state network with a randomly initialized recurrent reservoir and a ridge regression readout.
#' Quantile predictions are empirical quantiles of the future paths simulated by [echos::forecast_esn()].
#' Calls [echos::train_esn()] and [echos::forecast_esn()] from package \CRANpkg{echos}.
#'
#' @templateVar id fcst.esn
#' @template learner
#'
#' @references
#' `r format_bib("haeusser2026echo")`
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerFcstEsn = R6Class(
  "LearnerFcstEsn",
  inherit = LearnerFcst,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        lags = p_uty(
          default = 1L,
          tags = "train",
          custom_check = crate(function(x) check_integerish(x, lower = 1L, any.missing = FALSE, min.len = 1L))
        ),
        inf_crit = p_fct(c("aic", "aicc", "bic", "hqc"), default = "bic", tags = "train"),
        n_diff = p_int(0L, default = NULL, special_vals = list(NULL), tags = "train"),
        n_states = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        n_models = p_int(1L, default = NULL, special_vals = list(NULL), tags = "train"),
        n_initial = p_int(0L, default = NULL, special_vals = list(NULL), tags = "train"),
        n_seed = p_int(0L, .Machine$integer.max, default = 42L, tags = c("train", "predict")),
        alpha = p_dbl(0, 1, default = 1, tags = "train"),
        rho = p_dbl(0, default = 1, tags = "train"),
        tau = p_dbl(0, 1, default = 0.4, tags = "train"),
        density = p_dbl(0, 1, default = 0.5, tags = "train"),
        lambda = p_uty(
          default = c(1e-4, 2),
          tags = "train",
          custom_check = crate(function(x) {
            check = check_numeric(x, lower = 0, finite = TRUE, any.missing = FALSE, len = 2L)
            if (!isTRUE(check)) {
              return(check)
            }
            if (x[1L] >= x[2L]) "Must be strictly increasing." else TRUE
          })
        ),
        scale_win = p_dbl(0, default = 0.5, tags = "train"),
        scale_wres = p_dbl(0, default = 0.5, tags = "train"),
        scale_inputs = p_uty(
          default = c(-0.5, 0.5),
          tags = "train",
          custom_check = crate(function(x) {
            check = check_numeric(x, finite = TRUE, any.missing = FALSE, len = 2L)
            if (!isTRUE(check)) {
              return(check)
            }
            if (x[1L] >= x[2L]) "Must be strictly increasing." else TRUE
          })
        ),
        n_sim = p_int(1L, default = 100L, tags = "predict")
      )

      super$initialize(
        id = "fcst.esn",
        param_set = param_set,
        predict_types = c("response", "quantiles"),
        feature_types = unname(mlr_reflections$task_feature_types),
        properties = "featureless",
        packages = c("mlr3forecast", "echos"),
        label = "Echo State Network",
        man = "mlr3forecast::mlr_learners_fcst.esn"
      )
    }
  ),

  private = list(
    .train = function(task) {
      super$.train(task)
      pv = self$param_set$get_values(tags = "train")
      y = as.numeric(task$data(cols = task$target_names, ordered = TRUE)[[1L]])
      model = invoke(echos::train_esn, y = y, .args = pv)
      private$.set_context(model, task)
    },

    .fitted = function() {
      as.numeric(self$native_model$fitted)
    },

    .predict = function(task) {
      is_quantile = self$predict_type == "quantiles"
      if (is_quantile) {
        assert_quantiles(self, quantile_response = TRUE)
      }
      prediction = list(extra = as.list(task$data(cols = task$col_roles$order)))

      if (!private$.is_newdata(task)) {
        if (is_quantile) {
          error_config("Quantile prediction not supported for in-sample prediction.")
        }
        return(insert_named(prediction, list(response = private$.fitted_response(task))))
      }

      pv = self$param_set$get_values(tags = "predict")
      if (!is_quantile) {
        pv = insert_named(pv, list(n_sim = NULL))
      }
      pred = invoke(echos::forecast_esn, self$native_model, n_ahead = task$nrow, levels = 80, .args = pv)

      if (!is_quantile) {
        return(insert_named(prediction, list(response = as.numeric(pred$point))))
      }

      probs = private$.quantiles
      quantiles = matrix(
        vapply(
          seq_row(pred$sim),
          function(i) stats::quantile(pred$sim[i, ], probs = probs, names = FALSE),
          numeric(length(probs))
        ),
        nrow = length(probs),
        ncol = nrow(pred$sim)
      )
      quantiles = t(quantiles)
      setattr(quantiles, "probs", probs)
      setattr(quantiles, "response", private$.quantile_response)
      insert_named(prediction, list(quantiles = quantiles))
    }
  )
)

#' @include zzz.R
register_learner("fcst.esn", LearnerFcstEsn)
