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

# DirectForecaster errors on iterative feature PipeOps inside the graph

    Code
      DirectForecaster$new(graph, lags = 1:3, horizons = 3)
    Condition
      Error:
      ! 
      x Iterative feature PipeOps (property 'fcst_iterative') are not supported in a
        DirectForecaster graph (found: fcst.lags). Lags are handled internally via
        `lags`.
      > Class: Mlr3ErrorInput

---

    Code
      DirectForecaster$new(graph, lags = 1:3, horizons = 3)
    Condition
      Error:
      ! 
      x Iterative feature PipeOps (property 'fcst_iterative') are not supported in a
        DirectForecaster graph (found: fcst.rolling). Lags are handled internally via
        `lags`.
      > Class: Mlr3ErrorInput

