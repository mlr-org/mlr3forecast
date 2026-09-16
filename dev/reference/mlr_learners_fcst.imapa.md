# Intermittent MAPA Forecast Learner

Intermittent multiple aggregation prediction algorithm (iMAPA). The
series is temporally aggregated at several levels, Croston, SBA, or SES
is selected and fitted at each level, and the resulting demand rates are
combined into a single forecast. Calls
[`tsintermittent::imapa()`](https://rdrr.io/pkg/tsintermittent/man/imapa.html)
from package
[tsintermittent](https://CRAN.R-project.org/package=tsintermittent).

The wrapped function estimates and forecasts in one call, so prediction
re-runs it on the training series with the fitted `model.fit` object and
the requested horizon.

## Dictionary

This [mlr3::Learner](https://mlr3.mlr-org.com/reference/Learner.html)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr3::mlr_learners](https://mlr3.mlr-org.com/reference/mlr_learners.html)
or with the associated sugar function
[`mlr3::lrn()`](https://mlr3.mlr-org.com/reference/mlr_sugar.html):

    mlr_learners$get("fcst.imapa")
    lrn("fcst.imapa")

## Meta Information

- Task type: “fcst”

- Predict Types: “response”

- Feature Types: “logical”, “integer”, “numeric”, “character”, “factor”,
  “ordered”, “POSIXct”, “Date”

- Required Packages: [mlr3](https://CRAN.R-project.org/package=mlr3),
  [mlr3forecast](https://CRAN.R-project.org/package=mlr3forecast),
  [tsintermittent](https://CRAN.R-project.org/package=tsintermittent)

## Parameters

|           |           |         |              |                  |
|-----------|-----------|---------|--------------|------------------|
| Id        | Type      | Default | Levels       | Range            |
| w         | untyped   | NULL    |              | \-               |
| minimumAL | integer   | 1       |              | \\\[1, \infty)\\ |
| maximumAL | integer   | NULL    |              | \\\[1, \infty)\\ |
| comb      | character | mean    | mean, median | \-               |
| init.opt  | logical   | TRUE    | TRUE, FALSE  | \-               |
| paral     | integer   | 0       |              | \\\[0, 2\]\\     |
| na.rm     | logical   | FALSE   | TRUE, FALSE  | \-               |

## References

Petropoulos F, Kourentzes N (2015). “Forecast combinations for
intermittent demand.” *Journal of the Operational Research Society*,
**66**(6), 914–924.
[doi:10.1057/jors.2014.62](https://doi.org/10.1057/jors.2014.62) .

Kourentzes N (2014). “On intermittent demand model optimisation and
selection.” *International Journal of Production Economics*, **156**,
180–190.
[doi:10.1016/j.ijpe.2014.06.007](https://doi.org/10.1016/j.ijpe.2014.06.007)
.

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
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcst.md),
[`mlr_learners_fcst.adam`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.adam.md),
[`mlr_learners_fcst.ar`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ar.md),
[`mlr_learners_fcst.arfima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.arfima.md),
[`mlr_learners_fcst.arima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.arima.md),
[`mlr_learners_fcst.auto_adam`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_adam.md),
[`mlr_learners_fcst.auto_arima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_arima.md),
[`mlr_learners_fcst.auto_ces`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_ces.md),
[`mlr_learners_fcst.auto_gum`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_gum.md),
[`mlr_learners_fcst.auto_msarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_msarima.md),
[`mlr_learners_fcst.auto_ssarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.auto_ssarima.md),
[`mlr_learners_fcst.bagged`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.bagged.md),
[`mlr_learners_fcst.bats`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.bats.md),
[`mlr_learners_fcst.ces`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ces.md),
[`mlr_learners_fcst.croston`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.croston.md),
[`mlr_learners_fcst.dotm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.dotm.md),
[`mlr_learners_fcst.dstm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.dstm.md),
[`mlr_learners_fcst.elm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.elm.md),
[`mlr_learners_fcst.es`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.es.md),
[`mlr_learners_fcst.esn`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.esn.md),
[`mlr_learners_fcst.ets`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ets.md),
[`mlr_learners_fcst.gum`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.gum.md),
[`mlr_learners_fcst.holt_winters`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.holt_winters.md),
[`mlr_learners_fcst.mean`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mean.md),
[`mlr_learners_fcst.mlp`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.mlp.md),
[`mlr_learners_fcst.msarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.msarima.md),
[`mlr_learners_fcst.nnetar`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.nnetar.md),
[`mlr_learners_fcst.otm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.otm.md),
[`mlr_learners_fcst.prophet`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.prophet.md),
[`mlr_learners_fcst.random_walk`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.random_walk.md),
[`mlr_learners_fcst.rlgt`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.rlgt.md),
[`mlr_learners_fcst.sma`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.sma.md),
[`mlr_learners_fcst.snaive`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.snaive.md),
[`mlr_learners_fcst.sparma`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.sparma.md),
[`mlr_learners_fcst.spline`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.spline.md),
[`mlr_learners_fcst.ssarima`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.ssarima.md),
[`mlr_learners_fcst.stheta`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.stheta.md),
[`mlr_learners_fcst.stlm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.stlm.md),
[`mlr_learners_fcst.stm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.stm.md),
[`mlr_learners_fcst.struct_ts`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.struct_ts.md),
[`mlr_learners_fcst.tbats`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tbats.md),
[`mlr_learners_fcst.theta`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.theta.md),
[`mlr_learners_fcst.tscount`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tscount.md),
[`mlr_learners_fcst.tslm`](https://mlr3forecast.mlr-org.com/dev/reference/mlr_learners_fcst.tslm.md)

## Super classes

[`mlr3::Learner`](https://mlr3.mlr-org.com/reference/Learner.html) -\>
[`mlr3::LearnerRegr`](https://mlr3.mlr-org.com/reference/LearnerRegr.html)
-\>
[`LearnerFcst`](https://mlr3forecast.mlr-org.com/dev/reference/LearnerFcst.md)
-\> `LearnerFcstImapa`

## Methods

### Public methods

- [`LearnerFcstImapa$new()`](#method-LearnerFcstImapa-initialize)

- [`LearnerFcstImapa$clone()`](#method-LearnerFcstImapa-clone)

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

### `LearnerFcstImapa$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    LearnerFcstImapa$new()

------------------------------------------------------------------------

### `LearnerFcstImapa$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LearnerFcstImapa$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Define the Learner and set parameter values
learner = lrn("fcst.imapa")
print(learner)
#> 
#> ── <LearnerFcstImapa> (fcst.imapa): Intermittent MAPA ──────────────────────────
#> • Model: -
#> • Parameters: list()
#> • Packages: mlr3, mlr3forecast, and tsintermittent
#> • Predict Types: [response]
#> • Feature Types: logical, integer, numeric, character, factor, ordered,
#> POSIXct, and Date
#> • Encapsulation: none (fallback: -)
#> • Properties: featureless
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
#> $model$frc.in
#>  [1]       NA       NA       NA       NA       NA       NA       NA       NA
#>  [9]       NA       NA       NA       NA       NA       NA       NA       NA
#> [17] 154.3043 154.2948 153.7822 153.3326 153.0944 152.9568 152.9610 152.9421
#> [25] 151.6547 151.6595 151.1790 150.5216 150.1800 150.2041 149.6919 149.8789
#> [33] 150.5922 150.4681 150.5259 150.5271 150.8120 150.8317 150.9039 151.5542
#> [41] 152.3019 152.7478 154.0437 154.1045 154.8628 155.7649 156.5964 156.9290
#> [49] 160.2215 160.2523 161.5875 163.0141 165.3284 165.3808 168.3746 168.4513
#> [57] 171.9911 172.8953 174.4419 174.4509 177.4654 177.9698 178.8877 179.6001
#> [65] 180.9909 181.0376 183.1121 183.2080 185.0315 185.8948 186.6179 186.9540
#> [73] 190.6276 192.4321 194.8420 196.8644 199.2529 200.4366 203.0147 204.5161
#> [81] 207.2513 209.4532 211.3934 212.3274 214.3894 215.4757 216.8390 217.9259
#> [89] 219.0151 219.5705 220.7239 221.4298 222.3822 222.8953 223.1227 223.1571
#> 
#> $model$frc.out
#> [1] 256.6145 256.6145
#> 
#> $model$summary
#>              AL1       AL2        AL3        AL4        AL5       AL6
#> AL     1.0000000  2.000000  3.0000000  4.0000000  5.0000000  6.000000
#> n     96.0000000 48.000000 32.0000000 24.0000000 19.0000000 16.000000
#> p      1.0000000  1.000000  1.0000000  1.0000000  1.0000000  1.000000
#> cv2    0.1132491  0.111775  0.1107709  0.1078085  0.1036327  0.102083
#> model  3.0000000  3.000000  3.0000000  3.0000000  3.0000000  3.000000
#> use    1.0000000  1.000000  1.0000000  1.0000000  1.0000000  1.000000
#>               AL7        AL8         AL9        AL10        AL11       AL12
#> AL     7.00000000  8.0000000  9.00000000 10.00000000 11.00000000 12.0000000
#> n     13.00000000 12.0000000 10.00000000  9.00000000  8.00000000  8.0000000
#> p      1.00000000  1.0000000  1.00000000  1.00000000  1.00000000  1.0000000
#> cv2    0.09483907  0.1048261  0.09345737  0.09587789  0.09517166  0.1065288
#> model  3.00000000  3.0000000  3.00000000  3.00000000  3.00000000  3.0000000
#> use    1.00000000  1.0000000  1.00000000  1.00000000  1.00000000  1.0000000
#>              AL13        AL14        AL15       AL16      AL17       AL18
#> AL    13.00000000 14.00000000 15.00000000 16.0000000 17.000000 18.0000000
#> n      7.00000000  6.00000000  6.00000000  6.0000000  5.000000  5.0000000
#> p      1.00000000  1.00000000  1.00000000  1.0000000  1.000000  1.0000000
#> cv2    0.09269045  0.08071774  0.09462306  0.1076405  0.088332  0.1018927
#> model  3.00000000  3.00000000  3.00000000  3.0000000  3.000000  3.0000000
#> use    1.00000000  1.00000000  1.00000000  1.0000000  1.000000  1.0000000
#>             AL19        AL20        AL21       AL22       AL23       AL24 AL25
#> AL    19.0000000 20.00000000 21.00000000 22.0000000 23.0000000 24.0000000   25
#> n      5.0000000  4.00000000  4.00000000  4.0000000  4.0000000  4.0000000    3
#> p      1.0000000  1.00000000  1.00000000  1.0000000  1.0000000  1.0000000   NA
#> cv2    0.1114602  0.07987363  0.09004215  0.1047039  0.1114554  0.1187354   NA
#> model  3.0000000  3.00000000  3.00000000  3.0000000  3.0000000  3.0000000   NA
#> use    1.0000000  1.00000000  1.00000000  1.0000000  1.0000000  1.0000000    0
#>       AL26 AL27 AL28 AL29 AL30 AL31 AL32 AL33 AL34 AL35 AL36 AL37 AL38 AL39
#> AL      26   27   28   29   30   31   32   33   34   35   36   37   38   39
#> n        3    3    3    3    3    3    3    2    2    2    2    2    2    2
#> p       NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> cv2     NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> model   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> use      0    0    0    0    0    0    0    0    0    0    0    0    0    0
#>       AL40 AL41 AL42 AL43 AL44 AL45 AL46 AL47 AL48
#> AL      40   41   42   43   44   45   46   47   48
#> n        2    2    2    2    2    2    2    2    2
#> p       NA   NA   NA   NA   NA   NA   NA   NA   NA
#> cv2     NA   NA   NA   NA   NA   NA   NA   NA   NA
#> model   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> use      0    0    0    0    0    0    0    0    0
#> 
#> $model$model.fit
#>                    AL1          AL2          AL3          AL4          AL5
#> AL          1.00000000   2.00000000   3.00000000   4.00000000   5.00000000
#> model       3.00000000   3.00000000   3.00000000   3.00000000   3.00000000
#> a1          0.01809906   0.03716263   0.05733418   0.07527409   0.09931662
#> a2                  NA           NA           NA           NA           NA
#> initial.z 141.15518723 285.32107360 428.42110252 591.12318521 733.06365800
#> initial.x           NA           NA           NA           NA           NA
#>                   AL6        AL7          AL8         AL9         AL10
#> AL          6.0000000    7.00000    8.0000000    9.000000   10.0000000
#> model       3.0000000    3.00000    3.0000000    3.000000    3.0000000
#> a1          0.1236965    0.15074    0.1744078    0.206436    0.2448405
#> a2                 NA         NA           NA          NA           NA
#> initial.z 859.2320897 1077.16751 1200.8463804 1401.616551 1564.1148257
#> initial.x          NA         NA           NA          NA           NA
#>                  AL11         AL12         AL13         AL14         AL15
#> AL          11.000000   12.0000000   13.0000000   14.0000000   15.0000000
#> model        3.000000    3.0000000    3.0000000    3.0000000    3.0000000
#> a1           0.282703    0.2803524    0.2824887    0.3521853    0.3464555
#> a2                 NA           NA           NA           NA           NA
#> initial.z 1804.654059 1834.0426850 2222.5691686 2357.6846856 2342.7766759
#> initial.x          NA           NA           NA           NA           NA
#>                 AL16         AL17         AL18         AL19         AL20
#> AL          16.00000   17.0000000   18.0000000   19.0000000   20.0000000
#> model        3.00000    3.0000000    3.0000000    3.0000000    3.0000000
#> a1           0.34945    0.4775169    0.5080332    0.5329871    0.7985319
#> a2                NA           NA           NA           NA           NA
#> initial.z 2425.90168 2821.5000237 2808.5000890 2835.0001599 3717.9999944
#> initial.x         NA           NA           NA           NA           NA
#>                   AL21         AL22         AL23         AL24 AL25 AL26 AL27
#> AL          21.0000000   22.0000000   23.0000000   24.0000000   25   26   27
#> model        3.0000000    3.0000000    3.0000000    3.0000000   NA   NA   NA
#> a1           0.7723609    0.7323856    0.7028305    0.7016632   NA   NA   NA
#> a2                  NA           NA           NA           NA   NA   NA   NA
#> initial.z 3708.4999900 3711.0000763 3751.5000303 3800.9999922   NA   NA   NA
#> initial.x           NA           NA           NA           NA   NA   NA   NA
#>           AL28 AL29 AL30 AL31 AL32 AL33 AL34 AL35 AL36 AL37 AL38 AL39 AL40 AL41
#> AL          28   29   30   31   32   33   34   35   36   37   38   39   40   41
#> model       NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> a1          NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> a2          NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> initial.z   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#> initial.x   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA
#>           AL42 AL43 AL44 AL45 AL46 AL47 AL48
#> AL          42   43   44   45   46   47   48
#> model       NA   NA   NA   NA   NA   NA   NA
#> a1          NA   NA   NA   NA   NA   NA   NA
#> a2          NA   NA   NA   NA   NA   NA   NA
#> initial.z   NA   NA   NA   NA   NA   NA   NA
#> initial.x   NA   NA   NA   NA   NA   NA   NA
#> 
#> $model$data
#>  [1] 112 118 132 129 121 135 148 148 136 119 104 118 115 126 141 135 125 149 170
#> [20] 170 158 133 114 140 145 150 178 163 172 178 199 199 184 162 146 166 171 180
#> [39] 193 181 183 218 230 242 209 191 172 194 196 196 236 235 229 243 264 272 237
#> [58] 211 180 201 204 188 235 227 234 264 302 293 259 229 203 229 242 233 267 269
#> [77] 270 315 364 347 312 274 237 278 284 277 317 313 318 374 413 405 355 306 271
#> [96] 306
#> 
#> 
#> $row_ids
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#> [26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50
#> [51] 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75
#> [76] 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96
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
#> 30640.15 
```
