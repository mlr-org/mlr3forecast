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
      x Iterative feature PipeOps (property 'fcst_iterative') inside a
        DirectForecaster graph are not supported (found: fcst.lags). DirectForecaster
        manages lag features internally with horizon-shifted offsets via `lags`;
        other iterative features (e.g. PipeOpFcstRolling) cannot yet be
        horizon-offset and would leak future information for horizons > 1.
      > Class: Mlr3ErrorInput

---

    Code
      DirectForecaster$new(graph, lags = 1:3, horizons = 3)
    Condition
      Error:
      ! 
      x Iterative feature PipeOps (property 'fcst_iterative') inside a
        DirectForecaster graph are not supported (found: fcst.rolling).
        DirectForecaster manages lag features internally with horizon-shifted offsets
        via `lags`; other iterative features (e.g. PipeOpFcstRolling) cannot yet be
        horizon-offset and would leak future information for horizons > 1.
      > Class: Mlr3ErrorInput

