# quantiles 0 and 1 are rejected

    Code
      lower$predict(task, 133L)
    Condition
      Error:
      ! 
      x Quantiles 0 and 1 are not supported by fcst.arima.
      > Class: Mlr3ErrorConfig

---

    Code
      upper$predict(task, 133L)
    Condition
      Error:
      ! 
      x Quantiles 0 and 1 are not supported by fcst.arima.
      > Class: Mlr3ErrorConfig

