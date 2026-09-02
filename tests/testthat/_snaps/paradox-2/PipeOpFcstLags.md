# PipeOpFcstLags rejects non-positive lags

    Code
      po("fcst.lags", lags = 0L)
    Condition
      Error in `.__paradox2_ParamSet__values()`:
      ! Assertion on 'xs' failed: lags: Element 1 is not >= 1.

---

    Code
      po("fcst.lags", lags = c(1L, -1L))
    Condition
      Error in `.__paradox2_ParamSet__values()`:
      ! Assertion on 'xs' failed: lags: Element 2 is not >= 1.
