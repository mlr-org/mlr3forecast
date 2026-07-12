# PipeOpFcstAvg errors when only some members predict quantiles

    Code
      as_learner(graph)$train(task, 1:132)$predict(task, 133:144)
    Condition
      Error:
      ! 
      x Cannot average predictions: some predict quantiles, others do not.
      > Class: Mlr3ErrorInput
      
      This happened in PipeOp fcstavg's $predict()

