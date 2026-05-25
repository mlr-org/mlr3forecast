# as_learner_fcst rejects mismatched horizons and strategy

    Code
      as_learner_fcst(lrn("regr.rpart"), lags = 1:3, strategy = "direct")
    Condition
      Error:
      ! 
      x `horizons` is required when strategy = "direct".
      > Class: Mlr3ErrorInput

---

    Code
      as_learner_fcst(lrn("regr.rpart"), lags = 1:3, horizons = 3)
    Condition
      Error:
      ! 
      x `horizons` must be NULL when strategy = "recursive".
      > Class: Mlr3ErrorInput

# DirectForecaster errors on PipeOpFcstLags inside the graph

    Code
      DirectForecaster$new(graph, lags = 1:3, horizons = 3)
    Condition
      Error:
      ! 
      x PipeOpFcstLags inside a DirectForecaster graph is not supported (found:
        fcst.lags); lag features are managed internally with horizon-shifted offsets.
      > Class: Mlr3ErrorInput

