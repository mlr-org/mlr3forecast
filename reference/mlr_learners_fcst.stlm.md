# STL + ETS/ARIMA Forecast Learner

Forecasts of seasonal time series using STL decomposition. The seasonal
component is forecast naively and the seasonally-adjusted series is
forecast with either an `ETS` or `ARIMA` model. Calls
[`forecast::stlm()`](https://pkg.robjhyndman.com/forecast/reference/stlm.html)
from package [forecast](https://CRAN.R-project.org/package=forecast).

The task must provide a seasonal time series (frequency \> 1).

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.stlm")
    lrn("fcst.stlm")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”, “quantiles”

- Feature Types: “logical”, “integer”, “numeric”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [forecast](https://CRAN.R-project.org/package=forecast)

## Parameters

|  |  |  |  |  |
|----|----|----|----|----|
| Id | Type | Default | Levels | Range |
| s.window | untyped | 7L + 4L \* seq_len(6L) |  | \- |
| t.window | integer | NULL |  | \\\[1, \infty)\\ |
| robust | logical | FALSE | TRUE, FALSE | \- |
| method | character | ets | ets, arima | \- |
| modelfunction | untyped | NULL |  | \- |
| etsmodel | untyped | "ZZN" |  | \- |
| lambda | untyped | NULL |  | \- |
| biasadj | logical | FALSE | TRUE, FALSE | \- |
| allow.multiplicative.trend | logical | FALSE | TRUE, FALSE | \- |

## References

Cleveland RB, Cleveland WS, McRae JE, Terpenning I (1990). “STL: A
Seasonal-Trend Decomposition Procedure Based on Loess.” *Journal of
Official Statistics*, **6**(1), 3–73.

Hyndman RJ, Athanasopoulos G (2018). *Forecasting: principles and
practice*, 2nd edition. OTexts, Melbourne, Australia.
<https://OTexts.com/fpp2/>.

## See also

- Chapter in the [mlr3book](https://mlr3book.mlr-org.com/):
  <https://mlr3book.mlr-org.com/chapters/chapter2/data_and_basic_modeling.html#sec-learners>

- Package
  [mlr3learners](https://CRAN.R-project.org/package=mlr3learners) for a
  solid collection of essential learners.

- Package
  [mlr3extralearners](https://github.com/mlr-org/mlr3extralearners) for
  more learners.

- [Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  of [Learners](https://mlr3.mlr-org.com/reference/Learner.html):
  [mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)

- `as.data.table(mlr_learners)` for a table of available
  [Learners](https://mlr3.mlr-org.com/reference/Learner.html) in the
  running session (depending on the loaded packages).

- [mlr3pipelines](https://CRAN.R-project.org/package=mlr3pipelines) to
  combine learners with pre- and postprocessing steps.

- Package [mlr3viz](https://CRAN.R-project.org/package=mlr3viz) for some
  generic visualizations.

- Extension packages for additional task types:

  - [mlr3proba](https://CRAN.R-project.org/package=mlr3proba) for
    probabilistic supervised regression and survival analysis.

  - [mlr3cluster](https://CRAN.R-project.org/package=mlr3cluster) for
    unsupervised clustering.

- [mlr3tuning](https://CRAN.R-project.org/package=mlr3tuning) for tuning
  of hyperparameters,
  [mlr3tuningspaces](https://CRAN.R-project.org/package=mlr3tuningspaces)
  for established default tuning spaces.

Other Learner:
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md),
[`mlr_learners_fcst.adam`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.adam.md),
[`mlr_learners_fcst.arfima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.arfima.md),
[`mlr_learners_fcst.arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.arima.md),
[`mlr_learners_fcst.auto_adam`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_adam.md),
[`mlr_learners_fcst.auto_arima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_arima.md),
[`mlr_learners_fcst.auto_ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_ces.md),
[`mlr_learners_fcst.auto_gum`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_gum.md),
[`mlr_learners_fcst.auto_msarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_msarima.md),
[`mlr_learners_fcst.auto_ssarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.auto_ssarima.md),
[`mlr_learners_fcst.bagged`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.bagged.md),
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.croston`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.croston.md),
[`mlr_learners_fcst.elm`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.elm.md),
[`mlr_learners_fcst.es`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.es.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.gum`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.gum.md),
[`mlr_learners_fcst.holt_winters`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.holt_winters.md),
[`mlr_learners_fcst.mean`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.mean.md),
[`mlr_learners_fcst.mlp`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.mlp.md),
[`mlr_learners_fcst.msarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.msarima.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.prophet`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.prophet.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.rlgt`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.rlgt.md),
[`mlr_learners_fcst.sma`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.sma.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.ssarima`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.ssarima.md),
[`mlr_learners_fcst.struct_ts`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.struct_ts.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.theta.md),
[`mlr_learners_fcst.tscount`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tscount.md),
[`mlr_learners_fcst.tslm`](https://mlr3forecast.mlr-org.com/reference/mlr_learners_fcst.tslm.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/reference/LearnerFcst.md)
-\>
[`LearnerFcstForecast`](https://mlr3forecast.mlr-org.com/reference/LearnerFcstForecast.md)
-\> `LearnerFcstStlm`

## Methods

### Public methods

- [`LearnerFcstStlm$new()`](#method-LearnerFcstStlm-initialize)

- [`LearnerFcstStlm$clone()`](#method-LearnerFcstStlm-clone)

Inherited methods

- [`mlr3::Learner$base_learner()`](https://mlr3.mlr-org.com/reference/Learner.html#method-base_learner)
- [`mlr3::Learner$configure()`](https://mlr3.mlr-org.com/reference/Learner.html#method-configure)
- [`mlr3::Learner$encapsulate()`](https://mlr3.mlr-org.com/reference/Learner.html#method-encapsulate)
- [`mlr3::Learner$format()`](https://mlr3.mlr-org.com/reference/Learner.html#method-format)
- [`mlr3::Learner$help()`](https://mlr3.mlr-org.com/reference/Learner.html#method-help)
- [`mlr3::Learner$predict()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict)
- [`mlr3::Learner$predict_newdata()`](https://mlr3.mlr-org.com/reference/Learner.html#method-predict_newdata)
- [`mlr3::Learner$print()`](https://mlr3.mlr-org.com/reference/Learner.html#method-print)
- [`mlr3::Learner$reset()`](https://mlr3.mlr-org.com/reference/Learner.html#method-reset)
- [`mlr3::Learner$selected_features()`](https://mlr3.mlr-org.com/reference/Learner.html#method-selected_features)
- [`mlr3::Learner$train()`](https://mlr3.mlr-org.com/reference/Learner.html#method-train)
- [`mlr3::LearnerRegr$predict_newdata_fast()`](https://mlr3.mlr-org.com/reference/LearnerRegr.html#method-predict_newdata_fast)

------------------------------------------------------------------------

### `LearnerFcstStlm$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    LearnerFcstStlm$new()

------------------------------------------------------------------------

### `LearnerFcstStlm$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstStlm$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.stlm")
print(learner)
#> 
#> ── <LearnerFcstStlm> (fcst.stlm): STL + ETS/ARIMA ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and forecast
#> • Predict Types: [response] and quantiles
#> • Feature Types: logical, integer, and numeric
#> • Encapsulation: none (fallback: -)
#> • Properties: exogenous, featureless, and missings
#> • Other settings: use_weights = 'error', predict_raw = 'FALSE'

# Define a Task
task = tsk("airpassengers")

# Create train and test set
ids = partition(task)

# Train the learner on the training ids
learner$train(task, row_ids = ids$train)

# Print the model
print(learner$model)
#> $model
#> $stl
#>       Data    Trend  Seasonal12    Remainder
#> Jan 1  112 123.0401 -15.5513392   4.51121282
#> Feb 1  118 123.6446 -13.2998673   7.65526943
#> Mar 1  132 124.2491   8.7055477  -0.95461714
#> Apr 1  129 124.8535  -0.3144517   4.46091081
#> May 1  121 125.5478  -3.6201142  -0.92767397
#> Jun 1  135 126.2420  15.4287096  -6.67074505
#> Jul 1  148 126.9363  34.2983982 -13.23468087
#> Aug 1  148 127.5501  34.0364958 -13.58659858
#> Sep 1  136 128.1639  10.1677205  -2.33164336
#> Oct 1  119 128.7777 -14.6065330   4.82878996
#> Nov 1  104 129.7517 -37.4282019  11.67650092
#> Dec 1  118 130.7257 -17.7838961   5.05823722
#> Jan 2  115 131.6996 -15.8668637  -0.83275303
#> Feb 2  126 133.1327 -14.3395004   7.20676118
#> Mar 2  141 134.5659   8.5539151  -2.11977687
#> Apr 2  135 135.9990  -0.4233783  -0.57560593
#> May 2  125 137.7254  -3.4888577  -9.23650252
#> Jun 2  149 139.4517  16.1700606  -6.62179687
#> Jul 2  170 141.1781  35.7564358  -6.93454813
#> Aug 2  170 143.7207  35.2001969  -8.92088267
#> Sep 2  158 146.2633  10.3234424   1.41329839
#> Oct 2  133 148.8058 -14.9826510  -0.82318162
#> Nov 2  114 151.5161 -38.4471014   0.93102832
#> Dec 2  140 154.2263 -18.4243265   4.19801301
#> Jan 3  145 156.9366 -16.1808317   4.24427774
#> Feb 3  150 159.3527 -15.3635623   6.01083695
#> Mar 3  178 161.7689   8.4318684   7.79923481
#> Apr 3  163 164.1851  -0.4912496  -0.69381859
#> May 3  172 166.5030  -3.3050767   8.80205498
#> Jun 3  178 168.8210  16.9631118  -7.78408694
#> Jul 3  199 171.1389  37.2653494  -9.40427797
#> Aug 3  199 173.1573  36.3953302 -10.55267685
#> Sep 3  184 175.1758  10.4911529  -1.66691748
#> Oct 3  162 177.1942 -15.3805262   0.18634364
#> Nov 3  146 179.2709 -39.5215038   6.25057144
#> Dec 3  166 181.3477 -19.1627532   3.81507104
#> Jan 4  171 183.4244 -17.1889141   4.76448218
#> Feb 4  180 185.8577 -18.6850542  12.82731124
#> Mar 4  193 188.2911   7.6177104  -2.90876438
#> Apr 4  181 190.7244  -1.2885130  -8.43585207
#> May 4  183 193.1305  -3.1625075  -6.96799136
#> Jun 4  218 195.5366  19.8920858   2.57128156
#> Jul 4  230 197.9428  42.8035957 -10.74636219
#> Aug 4  242 200.9038  40.5740090   0.52221105
#> Sep 4  209 203.8648  11.2118329  -6.07662631
#> Oct 4  191 206.8258 -16.9847848   1.15897792
#> Nov 4  172 209.7850 -43.2852076   5.50025603
#> Dec 4  194 212.7441 -21.3292018   2.58510561
#> Jan 5  196 215.7032 -18.3380787  -1.36516221
#> Feb 5  196 217.7677 -22.1119199   0.34425556
#> Mar 5  236 219.8321   6.7338870   9.43402532
#> Apr 5  235 221.8965  -2.1266706  15.23015948
#> May 5  229 222.8456  -3.0320615   9.18643144
#> Jun 5  243 223.7947  22.8312514  -3.62600028
#> Jul 5  264 224.7439  48.3743484  -9.11821624
#> Aug 5  272 224.9628  44.7996083   2.23763331
#> Sep 5  237 225.1816  11.9938478  -0.17549663
#> Oct 5  211 225.4005 -18.5184417   4.11790231
#> Nov 5  180 226.3102 -46.9690428   0.65888536
#> Dec 5  201 227.2198 -23.4046200  -2.81515558
#> Jan 6  204 228.1294 -19.2415775  -4.88781627
#> Feb 6  188 229.9940 -24.1452244 -17.84874746
#> Mar 6  235 231.8585   5.8690146  -2.72756461
#> Apr 6  227 233.7231  -2.5765968  -4.14653134
#> May 6  234 236.1885  -3.2308744   1.04242163
#> Jun 6  264 238.6538  24.8353417   0.51088083
#> Jul 6  302 241.1191  51.9174417   8.96345614
#> Aug 6  293 244.2979  47.3615853   1.34047671
#> Sep 6  259 247.4768  12.7235923  -1.20036613
#> Oct 6  229 250.6556 -19.4431582  -2.21245144
#> Nov 6  203 254.4566 -49.0720324  -2.38454035
#> Dec 6  229 258.2575 -24.5595646  -4.69797128
#> Jan 7  242 262.0585 -20.1152607   0.05676168
#> Feb 7  233 266.1498 -26.1726425  -6.97716816
#> Mar 7  267 270.2411   4.9860995  -8.22722189
#> Apr 7  269 274.3324  -3.0615917  -2.27084235
#> May 7  270 278.2000  -3.4817821  -4.71819804
#> Jun 7  315 282.0675  26.7834970   6.14897666
#> Jul 7  364 285.9351  55.4007597  22.66416781
#> Aug 7  347 289.7388  49.8759229   7.38528878
#> Sep 7  312 293.5425  13.4178335   5.03966240
#> Oct 7  274 297.3462 -20.3801376  -2.96608226
#> Nov 7  237 301.4963 -51.1640444 -13.33225969
#> Dec 7  278 305.6464 -25.6767689  -1.96961938
#> Jan 8  284 309.7965 -20.5984650  -5.19800737
#> Feb 8  277 313.3614 -27.2960825  -9.06532915
#> Mar 8  317 316.9264   4.5158752  -4.44222615
#> Apr 8  313 320.4913  -3.2744516  -4.21683852
#> May 8  318 323.4757  -3.5876685  -1.88802328
#> Jun 8  374 326.4601  27.6565130  19.88339367
#> Jul 8  413 329.4445  57.1481223  26.40738275
#> Aug 8  405 332.5384  51.0279155  21.43368737
#> Sep 8  355 335.6323  13.7775257   5.59017494
#> Oct 8  306 338.7262 -20.7788133 -11.94738820
#> Nov 8  271 341.6456 -52.1633288 -18.48231891
#> Dec 8  306 344.5651 -26.2075274 -12.35756657
#> 
#> $model
#> ETS(M,A,N) 
#> 
#> Call:
#> ets(y = x, model = etsmodel, allow.multiplicative.trend = allow.multiplicative.trend)
#> 
#>   Smoothing parameters:
#>     alpha = 0.8695 
#>     beta  = 1e-04 
#> 
#>   Initial states:
#>     l = 126.8078 
#>     b = 1.9622 
#> 
#>   sigma:  0.039
#> 
#>      AIC     AICc      BIC 
#> 841.7013 842.3680 854.5230 
#> 
#> $modelfunction
#> function (x, ...) 
#> {
#>     ets(x, model = etsmodel, allow.multiplicative.trend = allow.multiplicative.trend, 
#>         ...)
#> }
#> <bytecode: 0x55c1603e69c0>
#> <environment: 0x55c1603e4668>
#> 
#> $lambda
#> NULL
#> 
#> $x
#>   Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#> 1 112 118 132 129 121 135 148 148 136 119 104 118
#> 2 115 126 141 135 125 149 170 170 158 133 114 140
#> 3 145 150 178 163 172 178 199 199 184 162 146 166
#> 4 171 180 193 181 183 218 230 242 209 191 172 194
#> 5 196 196 236 235 229 243 264 272 237 211 180 201
#> 6 204 188 235 227 234 264 302 293 259 229 203 229
#> 7 242 233 267 269 270 315 364 347 312 274 237 278
#> 8 284 277 317 313 318 374 413 405 355 306 271 306
#> 
#> $series
#> [1] "passengers"
#> 
#> $m
#> [1] 12
#> 
#> $fitted
#>         Jan       Feb       Mar       Apr       May       Jun       Jul       Aug       Sep       Oct       Nov       Dec
#> 1 113.21867 116.37258 141.75524 126.21442 127.29231 142.83093 156.85182 150.85258 126.46245 111.94087  97.21762 124.72040
#> 2 122.75473 119.49927 150.00547 135.15760 133.91465 147.78105 170.38607 171.45289 147.27147 133.25338 111.52827 135.66008
#> 3 143.63742 147.59991 175.44290 170.70412 163.15185 193.07448 202.22921 200.51068 175.25208 158.94658 139.42079 167.46102
#> 4 170.12531 171.35058 207.13566 187.89898 181.98604 207.88200 241.55174 231.23765 213.19388 183.31099 165.65709 195.08984
#> 5 199.09491 194.59132 226.62334 227.87800 235.12814 257.62553 272.41286 263.48335 240.04368 208.84561 184.22910 206.07682
#> 6 207.78557 201.54998 221.74088 226.78345 228.27702 263.27943 292.94826 298.22389 261.00438 229.05523 201.33871 229.25620
#> 7 235.43826 237.04741 266.64775 260.86715 269.48000 302.15909 343.90434 357.81742 313.91761 280.41600 246.01652 265.62619
#> 8 283.42677 279.19102 311.06115 310.39841 314.31134 350.72723 402.42103 407.46697 370.03919 324.37256 278.97758 299.96043
#> 
#> $residuals
#>             Jan           Feb           Mar           Apr           May           Jun           Jul           Aug           Sep           Oct           Nov           Dec
#> 1 -0.0094638944  0.0125502452 -0.0733202541  0.0220153934 -0.0480650067 -0.0614662323 -0.0722282825 -0.0244194337  0.0820118774  0.0557825059  0.0503719679 -0.0471592781
#> 2 -0.0559416902  0.0485713435 -0.0636646796 -0.0011624039 -0.0648793160  0.0092617789 -0.0028676561 -0.0106632270  0.0783401954 -0.0017093015  0.0164809116  0.0281658428
#> 3  0.0085258266  0.0147278014  0.0153109593 -0.0450019044  0.0531558097 -0.0855962963 -0.0195752462 -0.0092049744  0.0530946340  0.0175154357  0.0367671945 -0.0078287128
#> 4  0.0046696282  0.0455147136 -0.0708490611 -0.0364663588  0.0054764552  0.0538220435 -0.0581225220  0.0564467903 -0.0207636425  0.0383882867  0.0303572106 -0.0050357966
#> 5 -0.0142338702  0.0065004842  0.0426426045  0.0309645889 -0.0257311716 -0.0622908365 -0.0375509573  0.0389450461 -0.0133465636  0.0094755130 -0.0182921130 -0.0221230294
#> 6 -0.0166745392 -0.0600366328  0.0614212561  0.0009441501  0.0247204668  0.0030219694  0.0375542840 -0.0208237516 -0.0080730174 -0.0002222576  0.0066342410 -0.0010093838
#> 7  0.0256765687 -0.0153765359  0.0013461976  0.0308145856  0.0019050302  0.0466305305  0.0696548201 -0.0351281637 -0.0063814002 -0.0213300723 -0.0303402028  0.0424774438
#> 8  0.0018854660 -0.0071488277  0.0193734939  0.0082939534  0.0116032577  0.0720361553  0.0306394458 -0.0069211487 -0.0422138840 -0.0532304307 -0.0240911974  0.0185167516
#> 
#> attr(,"class")
#> [1] "fc_model" "stlm"    
#> 
#> $row_ids
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58
#> [59] 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96
#> 
#> $max_index
#> [1] "1956-12-01"
#> 
#> $step
#> [1] "month"
#> 

# Importance method
if ("importance" %in% learner$properties) print(learner$importance())

# Make predictions for the test rows
predictions = learner$predict(task, row_ids = ids$test)

# Score the predictions
predictions$score()
#> regr.mse 
#> 2681.242 
```
