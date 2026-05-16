# RecursiveForecaster errors on target trafo inside the graph

    Code
      RecursiveForecaster$new(graph)
    Condition
      Error:
      ! 
      x Target transformations inside a RecursiveForecaster graph are not supported
        (found: fcst.targetdiff). Apply the transformation outside the graph, or use
        DirectForecaster.
      > Class: Mlr3ErrorInput

