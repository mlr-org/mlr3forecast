walk(list.files(system.file("testthat", package = "mlr3"), pattern = "^helper.*\\.[rR]", full.names = TRUE), source)

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
  task = TaskFcst$new("proto", as_data_backend(data), target = "target", order = "date", freq = "daily")
  task$col_roles$feature = setdiff(task$col_roles$feature, "date")
  tasks[[1L]] = task

  # generate sanity task
  data = withr::with_seed(100, {
    dt = seq(from = as.Date("2020-01-01"), by = "day", length.out = 100L)
    y = seq(from = -10, to = 10, length.out = 100L)
    data.table(
      dt = dt,
      y = y,
      x = y + rnorm(length(y), mean = 1),
      unimportant = runif(length(y), min = 0, max = 1)
    )
  })
  tasks$sanity = TaskFcst$new("sanity", as_data_backend(data), target = "y", order = "dt")
  tasks$sanity_reordered = TaskFcst$new("sanity_reordered", as_data_backend(data), target = "y", order = "dt")

  tasks
}
registerS3method("generate_tasks", "LearnerFcst", generate_tasks.LearnerFcst, envir = parent.frame())
