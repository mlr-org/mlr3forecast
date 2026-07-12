as_pdata_regr = function(pdata) {
  set_class(pdata, c("PredictionDataRegr", "PredictionData"))
}

as_pdata_fcst = function(pdata) {
  set_class(pdata, c("PredictionDataFcst", "PredictionData"))
}

#' @export
as_prediction.PredictionDataFcst = function(x, check = FALSE, ...) {
  invoke(PredictionFcst$new, check = check, .args = x)
}

#' @export
check_prediction_data.PredictionDataFcst = function(pdata, ...) {
  pdata = check_prediction_data(as_pdata_regr(pdata), ...)
  as_pdata_fcst(pdata)
}

#' @export
is_missing_prediction_data.PredictionDataFcst = function(pdata, ...) {
  is_missing_prediction_data(as_pdata_regr(pdata), ...)
}

#' @export
c.PredictionDataFcst = function(..., keep_duplicates = TRUE) {
  dots = map(list(...), as_pdata_regr)
  quantiles = compact(map(dots, "quantiles"))
  if (length(quantiles) > 1L) {
    attrs = map(quantiles, function(q) list(attr(q, "probs"), attr(q, "response")))
    if (!every(attrs[-1L], identical, attrs[[1L]])) {
      error_input("Cannot combine predictions: different quantile levels.")
    }
  }
  result = invoke(c, .args = c(dots, list(keep_duplicates = keep_duplicates)))
  as_pdata_fcst(result)
}

#' @export
filter_prediction_data.PredictionDataFcst = function(pdata, row_ids, ...) {
  pdata = filter_prediction_data(as_pdata_regr(pdata), row_ids, ...)
  as_pdata_fcst(pdata)
}

#' @export
create_empty_prediction_data.TaskFcst = function(task, learner) {
  as_pdata_fcst(NextMethod())
}
