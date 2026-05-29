# stlm errors clearly when features are used without method = 'arima'

    Code
      learner$train(task)
    Condition
      Error:
      ! 
      x `fcst.stlm` supports exogenous features only with `method = "arima"` (current
        method: "ets").
      > Class: Mlr3ErrorInput

