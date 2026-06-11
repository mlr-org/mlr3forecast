# RecursiveForecaster errors when test rows do not continue the training grid

    Code
      flrn$predict(task, 126:130)
    Condition
      Error:
      ! 
      x Test rows must form the gap-free future grid following the training data
        (origin 1958-12-01, freq month).
      > Class: Mlr3ErrorInput

---

    Code
      flrn$predict(task, c(121L, 123L))
    Condition
      Error:
      ! 
      x Test rows must form the gap-free future grid following the training data
        (origin 1958-12-01, freq month).
      > Class: Mlr3ErrorInput

# RecursiveForecaster errors on gapped keyed test rows

    Code
      flrn$predict(task, 19:20)
    Condition
      Error:
      ! 
      x Test rows must form the gap-free future grid following the training data;
        offending key group(s): a, b.
      > Class: Mlr3ErrorInput

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

