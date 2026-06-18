# PipeOpFcstLags rejects non-positive lags

    Code
      po("fcst.lags", lags = 0L)
    Condition
      Error in `self$assert()`:
      ! Assertion on 'xs' failed: lags: Element 1 is not >= 1.

---

    Code
      po("fcst.lags", lags = c(1L, -1L))
    Condition
      Error in `self$assert()`:
      ! Assertion on 'xs' failed: lags: Element 2 is not >= 1.

# PipeOpFcstLags warns and drops a panel series too short for the lags

    Code
      out <- po("fcst.lags", lags = 1:5)$train(list(task))[[1L]]
    Condition
      Warning:
      
      x Dropped 1 series too short for the requested lags/windows: 'b'.
      > Class: Mlr3WarningInput
      
      This happened in PipeOp fcst.lags's $train()

# PipeOpFcstLags errors when the whole series is too short for the lags

    Code
      po("fcst.lags", lags = 1:5)$train(list(task))
    Condition
      Error:
      ! 
      x The series is too short for the requested lags or window sizes.
      > Class: Mlr3ErrorInput
      
      This happened in PipeOp fcst.lags's $train()

