# autoplot.TaskFcst rejects non-flag facets

    Code
      ggplot2::autoplot(tsk("airpassengers"), facets = "yes")
    Condition
      Error in `autoplot.TaskFcst()`:
      ! Assertion on 'facets' failed: Must be of type 'logical flag', not 'character'.

# autoplot.PredictionFcst rejects non-flag facets

    Code
      ggplot2::autoplot(p, facets = "yes")
    Condition
      Error in `autoplot.PredictionFcst()`:
      ! Assertion on 'facets' failed: Must be of type 'logical flag', not 'character'.

# autoplot.PredictionFcst errors without a time index and without task

    Code
      ggplot2::autoplot(p)
    Condition
      Error:
      ! 
      x Cannot determine the time index of the prediction.
      > Class: Mlr3ErrorInput

