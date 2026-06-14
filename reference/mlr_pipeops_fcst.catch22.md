# Time Series Feature Extraction (catch22)

Computes the 22 (or 24) canonical time-series characteristics of the
target variable via
[`Rcatch22::catch22_all()`](https://rdrr.io/pkg/Rcatch22/man/catch22_all.html),
and broadcasts them as constant columns to every row of the
corresponding series. For an unkeyed task the features are broadcast to
every row; for a keyed task each key contributes one feature vector.

The catch22 set is a low-redundancy subset of the hctsa features
selected for time-series classification performance and is computed in
C, making it considerably faster than
[PipeOpFcstTsfeats](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.tsfeats.md)
and
[PipeOpFcstFeasts](https://mlr3forecast.mlr-org.com/reference/mlr_pipeops_fcst.feasts.md).
The features are computed on the ordered target vector and are agnostic
to the seasonal period, so unlike the other two extractors they contain
no explicit seasonal/trend features.

Features are cached in the state at train time and reused at predict
time. Predicting on a key that was not seen during training is an error.

## Parameters

The parameters are the parameters inherited from
[mlr3pipelines::PipeOpTaskPreproc](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html),
as well as:

- `catch24` :: `logical(1)`  
  If `TRUE`, additionally compute the mean and standard deviation (the
  catch24 set). Default `FALSE`.

## Super classes

[`mlr3pipelines::PipeOp`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html)
-\>
[`mlr3pipelines::PipeOpTaskPreproc`](https://mlr3pipelines.mlr-org.com/reference/PipeOpTaskPreproc.html)
-\> `PipeOpFcstCatch22`

## Methods

### Public methods

- [`PipeOpFcstCatch22$new()`](#method-PipeOpFcstCatch22-initialize)

- [`PipeOpFcstCatch22$clone()`](#method-PipeOpFcstCatch22-clone)

Inherited methods

- [`mlr3pipelines::PipeOp$help()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-help)
- [`mlr3pipelines::PipeOp$predict()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-predict)
- [`mlr3pipelines::PipeOp$print()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-print)
- [`mlr3pipelines::PipeOp$train()`](https://mlr3pipelines.mlr-org.com/reference/PipeOp.html#method-train)

------------------------------------------------------------------------

### `PipeOpFcstCatch22$new()`

Initializes a new instance of this Class.

#### Usage

    PipeOpFcstCatch22$new(id = "fcst.catch22", param_vals = list())

#### Arguments

- `id`:

  (`character(1)`)  
  Identifier of resulting object, default `"fcst.catch22"`.

- `param_vals`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  List of hyperparameter settings, overwriting the hyperparameter
  settings that would otherwise be set during construction. Default
  [`list()`](https://rdrr.io/r/base/list.html).

------------------------------------------------------------------------

### `PipeOpFcstCatch22$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PipeOpFcstCatch22$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
library(mlr3pipelines)
task = tsk("airpassengers")
po = po("fcst.catch22")
out = po$train(list(task))[[1L]]
out$head()
#>    passengers passengers_catch22_DN_HistogramMode_5 passengers_catch22_DN_HistogramMode_10 passengers_catch22_CO_f1ecac passengers_catch22_CO_FirstMin_ac
#>         <num>                                 <num>                                  <num>                        <num>                             <num>
#> 1:        112                              -1.03778                             -0.8218858                     28.49835                                 8
#> 2:        118                              -1.03778                             -0.8218858                     28.49835                                 8
#> 3:        132                              -1.03778                             -0.8218858                     28.49835                                 8
#> 4:        129                              -1.03778                             -0.8218858                     28.49835                                 8
#> 5:        121                              -1.03778                             -0.8218858                     28.49835                                 8
#> 6:        135                              -1.03778                             -0.8218858                     28.49835                                 8
#>    passengers_catch22_CO_HistogramAMI_even_2_5 passengers_catch22_CO_trev_1_num passengers_catch22_MD_hrv_classic_pnn40 passengers_catch22_SB_BinaryStats_mean_longstretch1
#>                                          <num>                            <num>                                   <num>                                               <num>
#> 1:                                   0.7175964                     -0.002839309                               0.8951049                                                  48
#> 2:                                   0.7175964                     -0.002839309                               0.8951049                                                  48
#> 3:                                   0.7175964                     -0.002839309                               0.8951049                                                  48
#> 4:                                   0.7175964                     -0.002839309                               0.8951049                                                  48
#> 5:                                   0.7175964                     -0.002839309                               0.8951049                                                  48
#> 6:                                   0.7175964                     -0.002839309                               0.8951049                                                  48
#>    passengers_catch22_SB_TransitionMatrix_3ac_sumdiagcov passengers_catch22_PD_PeriodicityWang_th0_01 passengers_catch22_CO_Embed2_Dist_tau_d_expfit_meandiff
#>                                                    <num>                                        <num>                                                   <num>
#> 1:                                             0.1666667                                           11                                               0.6712426
#> 2:                                             0.1666667                                           11                                               0.6712426
#> 3:                                             0.1666667                                           11                                               0.6712426
#> 4:                                             0.1666667                                           11                                               0.6712426
#> 5:                                             0.1666667                                           11                                               0.6712426
#> 6:                                             0.1666667                                           11                                               0.6712426
#>    passengers_catch22_IN_AutoMutualInfoStats_40_gaussian_fmmi passengers_catch22_FC_LocalSimple_mean1_tauresrat passengers_catch22_DN_OutlierInclude_p_001_mdrmd
#>                                                         <num>                                             <num>                                            <num>
#> 1:                                                          5                                        0.03846154                                        0.7847222
#> 2:                                                          5                                        0.03846154                                        0.7847222
#> 3:                                                          5                                        0.03846154                                        0.7847222
#> 4:                                                          5                                        0.03846154                                        0.7847222
#> 5:                                                          5                                        0.03846154                                        0.7847222
#> 6:                                                          5                                        0.03846154                                        0.7847222
#>    passengers_catch22_DN_OutlierInclude_n_001_mdrmd passengers_catch22_SP_Summaries_welch_rect_area_5_1 passengers_catch22_SB_BinaryStats_diff_longstretch0
#>                                               <num>                                               <num>                                               <num>
#> 1:                                       -0.6736111                                           0.9485463                                                   5
#> 2:                                       -0.6736111                                           0.9485463                                                   5
#> 3:                                       -0.6736111                                           0.9485463                                                   5
#> 4:                                       -0.6736111                                           0.9485463                                                   5
#> 5:                                       -0.6736111                                           0.9485463                                                   5
#> 6:                                       -0.6736111                                           0.9485463                                                   5
#>    passengers_catch22_SB_MotifThree_quantile_hh passengers_catch22_SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1 passengers_catch22_SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
#>                                           <num>                                                          <num>                                                     <num>
#> 1:                                      1.50827                                                      0.7692308                                                 0.2820513
#> 2:                                      1.50827                                                      0.7692308                                                 0.2820513
#> 3:                                      1.50827                                                      0.7692308                                                 0.2820513
#> 4:                                      1.50827                                                      0.7692308                                                 0.2820513
#> 5:                                      1.50827                                                      0.7692308                                                 0.2820513
#> 6:                                      1.50827                                                      0.7692308                                                 0.2820513
#>    passengers_catch22_SP_Summaries_welch_rect_centroid passengers_catch22_FC_LocalSimple_mean3_stderr
#>                                                  <num>                                          <num>
#> 1:                                          0.02454369                                      0.4030752
#> 2:                                          0.02454369                                      0.4030752
#> 3:                                          0.02454369                                      0.4030752
#> 4:                                          0.02454369                                      0.4030752
#> 5:                                          0.02454369                                      0.4030752
#> 6:                                          0.02454369                                      0.4030752
```
