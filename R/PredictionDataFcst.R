as_pdata_regr = function(pdata) {
  set_class(pdata, c("PredictionDataRegr", "PredictionData"))
}

as_pdata_fcst = function(pdata) {
  set_class(pdata, c("PredictionDataFcst", "PredictionData"))
}

empty_fcst_prediction_col_roles = function() {
  list(order = character(), key = character())
}

fcst_prediction_col_roles = function(task, extra) {
  if (is.null(extra)) {
    return(empty_fcst_prediction_col_roles())
  }
  list(
    order = intersect(task$col_roles$order %??% character(), names(extra)),
    key = intersect(task$col_roles$key %??% character(), names(extra))
  )
}

check_fcst_prediction_col_roles = function(col_roles, extra) {
  assert_list(col_roles, names = "unique", .var.name = "col_roles")
  assert_names(names(col_roles), permutation.of = c("order", "key"), .var.name = "names of col_roles")
  col_roles = map(col_roles, assert_character, any.missing = FALSE, unique = TRUE)
  if (length(col_roles$order) > 1L) {
    error_learner_predict("There may only be up to one extra column with role 'order'")
  }
  if (length(intersect(col_roles$order, col_roles$key)) > 0L) {
    error_learner_predict("Extra column(s) may not have both the 'order' and the 'key' role")
  }
  assert_subset(unlist(col_roles, use.names = FALSE), names(extra), .var.name = "columns in col_roles")
  # canonical element order so downstream comparisons are representation-independent
  list(order = col_roles[["order"]], key = col_roles[["key"]])
}

#' @export
as_prediction.PredictionDataFcst = function(x, check = FALSE, ...) {
  invoke(PredictionFcst$new, check = check, .args = x)
}

#' @export
check_prediction_data.PredictionDataFcst = function(pdata, ..., train_task = NULL) {
  pdata = check_prediction_data(as_pdata_regr(pdata), ...)
  if (is.null(pdata$col_roles)) {
    pdata$col_roles = if (is.null(train_task)) {
      empty_fcst_prediction_col_roles()
    } else {
      fcst_prediction_col_roles(train_task, pdata$extra)
    }
  }
  pdata$col_roles = check_fcst_prediction_col_roles(pdata$col_roles, pdata$extra)
  as_pdata_fcst(pdata)
}

#' @export
is_missing_prediction_data.PredictionDataFcst = function(pdata, ...) {
  is_missing_prediction_data(as_pdata_regr(pdata), ...)
}

#' @export
c.PredictionDataFcst = function(..., keep_duplicates = TRUE) {
  dots = list(...)
  col_roles = map(dots, function(pdata) pdata$col_roles %??% empty_fcst_prediction_col_roles())
  ref = col_roles[[1L]]
  same_roles = every(col_roles[-1L], function(roles) {
    identical(roles$order, ref$order) && setequal(roles$key, ref$key)
  })
  if (!same_roles) {
    error_input("Cannot combine predictions: different extra column roles.")
  }
  dots = map(dots, as_pdata_regr)
  quantiles = compact(map(dots, "quantiles"))
  if (length(quantiles) > 1L) {
    attrs = map(quantiles, function(q) list(attr(q, "probs"), attr(q, "response")))
    if (!every(attrs[-1L], identical, attrs[[1L]])) {
      error_input("Cannot combine predictions: different quantile levels.")
    }
  }
  result = invoke(c, .args = c(dots, list(keep_duplicates = keep_duplicates)))
  result$col_roles = ref
  as_pdata_fcst(result)
}

#' @export
filter_prediction_data.PredictionDataFcst = function(pdata, row_ids, ...) {
  pdata = filter_prediction_data(as_pdata_regr(pdata), row_ids, ...)
  as_pdata_fcst(pdata)
}

#' @export
create_empty_prediction_data.TaskFcst = function(task, learner) {
  pdata = NextMethod()
  pdata$col_roles = empty_fcst_prediction_col_roles()
  as_pdata_fcst(pdata)
}
