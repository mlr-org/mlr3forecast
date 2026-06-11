# predict errors on mixed in-sample and future rows

    Code
      learner$predict(task, 130:135)
    Condition
      Error:
      ! 
      x Cannot mix in-sample and future rows in one predict() call (last training
        index: 1959-12-01).
      > Class: Mlr3ErrorInput

# in-sample predict errors for rows before the training window

    Code
      learner$predict(task, 10:20)
    Condition
      Error:
      ! 
      x In-sample prediction is only supported for rows used during training.
      > Class: Mlr3ErrorInput

