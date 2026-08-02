walk(
  list.files(system.file("testthat", package = "mlr3"), pattern = "^helper.*\\.[rR]", full.names = TRUE),
  source,
  local = environment()
)

generate_data = function(learner, N) {
  generate_feature = function(type) {
    switch(
      type,
      logical = sample(rep_len(c(TRUE, FALSE), N)),
      integer = sample(rep_len(1:3, N)),
      numeric = runif(N),
      character = sample(rep_len(letters[1:2], N)),
      factor = sample(factor(rep_len(c("f1", "f2"), N), levels = c("f1", "f2"))),
      ordered = sample(ordered(rep_len(c("o1", "o2"), N), levels = c("o1", "o2"))),
      POSIXct = Sys.time() - runif(N, min = 0, max = 10 * 365 * 24 * 60 * 60),
      Date = Sys.Date() - runif(N, min = 0, max = 10 * 365)
    )
  }
  types = unique(learner$feature_types)
  do.call(data.table, set_names(map(types, generate_feature), types))
}

generate_tasks.LearnerFcst = function(learner, N = 20L) {
  target = rnorm(N)
  data = cbind(
    data.table(target = target, date = seq(from = as.Date("2020-01-01"), by = "day", length.out = N)),
    generate_data(learner, N)
  )
  tasks = list()
  task = TaskFcst$new("proto", as_data_backend(data), target = "target", order = "date", freq = "day")
  task$col_roles$feature = setdiff(task$col_roles$feature, "date")
  tasks[[1L]] = task

  # generate sanity task
  withr::local_seed(100)
  dt = seq(from = as.Date("2020-01-01"), by = "day", length.out = 100L)
  y = seq(from = -10L, to = 10L, length.out = 100L)
  data = data.table(
    dt = dt,
    y = y,
    x = y + rnorm(length(y), mean = 1),
    unimportant = runif(length(y), min = 0, max = 1)
  )
  tasks$sanity = TaskFcst$new("sanity", as_data_backend(data), target = "y", order = "dt")
  tasks$sanity_reordered = TaskFcst$new("sanity_reordered", as_data_backend(data), target = "y", order = "dt")

  tasks
}

registerS3method("generate_tasks", "LearnerFcst", generate_tasks.LearnerFcst)

# keyed panel task whose backend is stored date-major, i.e. not in (key, order) sort
make_date_major_panel_task = function(n = 10L) {
  dates = seq(as.Date("2020-01-01"), by = "day", length.out = n)
  data = CJ(date = dates, id = c("a", "b"))
  data[, y := fifelse(id == "a", 0L, 100L) + rowid(id)]
  TaskFcst$new("panel", as_data_backend(data), target = "y", order = "date", key = "id", freq = "day")
}

# keyed monthly task with one multiplicative- and one additive-seasonal series (distinct Box-Cox lambdas)
make_monthly_panel_task = function(n = 36L) {
  months = seq(as.Date("2020-01-01"), by = "month", length.out = n)
  season = rep_len(sin(2 * pi * seq_len(12L) / 12), n)
  data = rbind(
    data.table(
      month = months,
      id = factor("a", levels = c("a", "b")),
      y = exp(seq(1, 3, length.out = n) + 0.5 * season)
    ),
    data.table(month = months, id = factor("b", levels = c("a", "b")), y = 100 + seq_len(n) + 5 * season)
  )
  TaskFcst$new("panel", as_data_backend(data), target = "y", order = "month", key = "id", freq = "month")
}

make_colon_key_panel_task = function(n = 12L) {
  dates = seq(as.Date("2020-01-01"), by = "day", length.out = n)
  data = rbind(
    data.table(
      date = dates,
      key1 = factor("x:y", levels = c("x:y", "x")),
      key2 = factor("z", levels = c("z", "y:z")),
      y = seq_len(n)
    ),
    data.table(
      date = dates,
      key1 = factor("x", levels = c("x:y", "x")),
      key2 = factor("y:z", levels = c("z", "y:z")),
      y = 100 + seq_len(n)^2
    )
  )
  TaskFcst$new("panel", as_data_backend(data), target = "y", order = "date", key = c("key1", "key2"), freq = "day")
}

fcst_prediction = function(task = tsk("airpassengers"), h = 12L) {
  learner = RecursiveForecaster$new(lrn("regr.rpart"), lags = 1:3)
  learner$train(task)
  forecast(learner, task, h = h)
}

# deterministic quantile forecast with widening central intervals
make_quantile_prediction = function(h = 12L, probs = c(0.05, 0.1, 0.5, 0.9, 0.95), start = as.Date("1961-01-01")) {
  response = 450 + 10 * sin(seq_len(h))
  quantiles = response + outer(seq_len(h) / 2, stats::qnorm(probs))
  colnames(quantiles) = sprintf("q%g", probs)
  setattr(quantiles, "probs", probs)
  setattr(quantiles, "response", 0.5)
  PredictionFcst$new(
    row_ids = seq_len(h),
    truth = rep(NA_real_, h),
    response = response,
    quantiles = quantiles,
    extra = list(month = seq(start, by = "month", length.out = h)),
    col_roles = list(order = "month", key = character())
  )
}

make_quantiles = function(lower, upper, probs = c(0.025, 0.975)) {
  q = cbind(lower, upper)
  colnames(q) = sprintf("q%s", probs)
  setattr(q, "probs", probs)
  setattr(q, "response", probs[1L])
  q
}

# regr learner advertising (and, unlike the hotstart properties, implementing) the optional
# properties the forecasters delegate to the wrapped graph; modeled on mlr3's classif.debug
make_property_stub_learner = function() {
  iter_aggr = crate(function(x) as.integer(ceiling(mean(unlist(x, use.names = FALSE)))), .parent = topenv())
  iter_tune_fn = crate(
    function(domain, param_vals) {
      assert_true(isTRUE(param_vals$early_stopping))
      domain$upper
    },
    .parent = topenv()
  )

  R6Class(
    "LearnerRegrPropertyStub",
    inherit = LearnerRegr,
    public = list(
      initialize = function() {
        super$initialize(
          id = "regr.stub",
          feature_types = c("logical", "integer", "numeric"),
          predict_types = "response",
          param_set = ps(
            shift = p_dbl(default = 0, tags = "train"),
            early_stopping = p_lgl(default = FALSE, tags = "train"),
            iter = p_int(
              1L,
              default = 1L,
              tags = c("train", "internal_tuning"),
              aggr = iter_aggr,
              in_tune_fn = iter_tune_fn,
              disable_in_tune = list(early_stopping = FALSE)
            )
          ),
          properties = c(
            "hotstart_backward",
            "hotstart_forward",
            "importance",
            "internal_tuning",
            "missings",
            "oob_error",
            "selected_features",
            "validation"
          )
        )
      },

      importance = function() {
        if (is.null(self$model)) {
          stopf("No model stored")
        }
        set_names(rev(seq_along(self$state$feature_names)), self$state$feature_names)
      },

      selected_features = function() {
        if (is.null(self$model)) {
          stopf("No model stored")
        }
        self$state$feature_names
      },

      oob_error = function() {
        if (is.null(self$model)) {
          stopf("No model stored")
        }
        self$model$oob_error
      }
    ),
    active = list(
      validate = function(rhs) {
        if (!missing(rhs)) {
          private$.validate = mlr3::assert_validate(rhs)
        }
        private$.validate
      },
      internal_valid_scores = function() self$state$internal_valid_scores,
      internal_tuned_values = function() self$state$internal_tuned_values
    ),
    private = list(
      .validate = NULL,

      .train = function(task) {
        pv = self$param_set$get_values(tags = "train")
        mean_val = mean(task$truth()) + (pv$shift %??% 0)
        if (isTRUE(pv$early_stopping) && is.null(task$internal_valid_task)) {
          stopf("Early stopping is only possible when a validation task is present.")
        }
        model = list(
          mean = mean_val,
          oob_error = 42,
          # "early stopping" deterministically halves the iteration budget
          iter = if (isTRUE(pv$early_stopping)) max(1L, (pv$iter %??% 1L) %/% 2L) else pv$iter %??% 1L
        )
        valid_task = task$internal_valid_task
        if (!is.null(valid_task)) {
          model$internal_valid_scores = list(mse = mean((valid_task$truth() - mean_val)^2))
        }
        model
      },

      .predict = function(task) list(response = rep(self$model$mean, task$nrow)),

      .extract_internal_valid_scores = function() {
        self$model$internal_valid_scores %??% named_list()
      },

      .extract_internal_tuned_values = function() {
        if (isTRUE(self$state$param_vals$early_stopping)) self$model["iter"] else named_list()
      }
    )
  )$new()
}
