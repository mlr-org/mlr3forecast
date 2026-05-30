# PipeOpFcstFourier errors when K exceeds period/2

    Code
      po("fcst.fourier", period = 4, K = 3L)$train(list(tsk("airpassengers")))
    Condition
      Error:
      ! 
      x `K` must not be greater than `period / 2`. Set a smaller `K` or a larger
        `period`.
      > Class: Mlr3ErrorInput
      
      This happened in PipeOp fcst.fourier's $train()

