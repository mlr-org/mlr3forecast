# PipeOpFcstSplitKey errors on tasks without keys

    Code
      po("fcst.splitkey")$train(list(tsk("airpassengers")))
    Condition
      Error:
      ! 
      x fcst.splitkey requires a task with key columns.
      > Class: Mlr3ErrorInput
      
      This happened in PipeOp fcst.splitkey's $train()

# PipeOpFcstSplitKey errors on unseen or missing keys at predict

    Code
      po_split$predict(list(task))
    Condition
      Error:
      ! 
      x Task has key group(s) not seen during training: 'b'.
      > Class: Mlr3ErrorInput
      
      This happened in PipeOp fcst.splitkey's $predict()

---

    Code
      po_split$predict(list(task$clone()$filter(rows_a)))
    Condition
      Error:
      ! 
      x Task is missing key group(s) seen during training: 'b'.
      > Class: Mlr3ErrorInput
      
      This happened in PipeOp fcst.splitkey's $predict()

