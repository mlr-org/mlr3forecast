# RecursiveForecaster errors on target trafo inside the graph

    Code
      RecursiveForecaster$new(graph)
    Condition
      Error:
      ! 
      x Target transformations inside a RecursiveForecaster graph are not supported
        (found: fcst.targetdiff). Wrap the forecaster with ppl("targettrafo")
        instead.
      > Class: Mlr3ErrorInput

