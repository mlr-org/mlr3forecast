#' @rdname as_prediction
#' @export
as_prediction.PredictionDataFcst = function(x, check = FALSE, ...) {
  invoke(PredictionFcst$new, check = check, .args = x)
}
