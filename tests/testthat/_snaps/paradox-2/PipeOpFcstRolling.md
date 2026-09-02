# PipeOpFcstRolling rejects non-integer finite window sizes

    Code
      po("fcst.rolling", window_sizes = 2.5)
    Condition
      Error in `.__paradox2_ParamSet__values()`:
      ! Assertion on 'xs' failed: window_sizes: Finite window sizes must be whole numbers. Use `Inf` for an expanding window.
