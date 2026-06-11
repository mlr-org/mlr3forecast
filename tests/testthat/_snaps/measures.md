# keyed scoring errors for key groups absent from the training set

    Code
      pred$score(msr("fcst.mase"), task = task, train_set = train_ids)
    Condition
      Error:
      ! 
      x Key group(s) 'Calves.Australian Capital Territory' have no observations in
        the training set.
      > Class: Mlr3ErrorInput

