# PipeOpFcstUniteKey errors on unnamed multiplicities

    Code
      po_unite$predict(list(Multiplicity(p1, p2)))
    Condition
      Error:
      ! 
      x fcst.unitekey requires a named multiplicity, as created by
        po("fcst.splitkey").
      > Class: Mlr3ErrorInput
      
      This happened in PipeOp fcst.unitekey's $predict()

