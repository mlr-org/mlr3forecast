# autoplot.TaskFcst rejects non-flag facets

    Code
      ggplot2::autoplot(tsk("airpassengers"), facets = "yes")
    Condition
      Error in `autoplot.TaskFcst()`:
      ! Assertion on 'facets' failed: Must be of type 'logical flag', not 'character'.

