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
  data = CJ(date = dates, id = factor(c("a", "b")))
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
    extra = list(month = seq(start, by = "month", length.out = h))
  )
}

make_quantiles = function(lower, upper, probs = c(0.025, 0.975)) {
  q = cbind(lower, upper)
  colnames(q) = sprintf("q%s", probs)
  setattr(q, "probs", probs)
  setattr(q, "response", probs[1L])
  q
}
