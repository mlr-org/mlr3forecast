# asymmetric quantiles raise a clear error

    Code
      learner$predict_newdata(generate_newdata(task, n = 6L))
    Condition
      Error:
      ! 
      x `fcst.*` learners only support quantiles symmetric around 0.5, e.g. `c(0.1,
        0.9)` or `c(0.05, 0.1, 0.9, 0.95)`.
      > Class: Mlr3ErrorConfig

