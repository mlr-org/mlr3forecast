# mlr3forecast — Package Review

A top-down review of the package, with particular attention to the
README and whether it represents the package’s functionality. Worked
through in small, discrete steps.

------------------------------------------------------------------------

## 1. README coverage of functionality

Question: *Does `README.Rmd` display all of the important functionality
of the package?*

Method: compared the features showcased in `README.Rmd` against all
exported objects in `NAMESPACE` (learners, measures, pipeops,
resamplings, tasks, and helper functions).

### What the README covers well

- Classical forecaster workflow: `train` → `predict` →
  [`generate_newdata()`](https://mlr3forecast.mlr-org.com/reference/generate_newdata.md)
  / `predict_newdata()` /
  [`forecast()`](https://generics.r-lib.org/reference/forecast.html)
- ML forecasting:
  [`recursive_forecaster()`](https://mlr3forecast.mlr-org.com/reference/recursive_forecaster.md)
  and
  [`direct_forecaster()`](https://mlr3forecast.mlr-org.com/reference/direct_forecaster.md)
- Temporal resamplings `fcst.holdout` / `fcst.cv`
- Feature engineering via `po("fcst.lags")` +
  [`selector_fcst_lags()`](https://mlr3forecast.mlr-org.com/reference/selector_fcst_lags.md)
- Quantile prediction (classical), exogenous covariates, benchmarking,
  ensembling (`po("regravg")`), tuning (`auto_tuner`), and global
  forecasting

### Notable gaps (advertised or important, but missing / under-shown)

1.  **The package’s own forecasting measures are never actually used.**
    Every `$score()` call in the README uses `msr("regr.rmse")`. Yet the
    package ships **12** forecasting measures: MASE, RMSSE, Pinball,
    Winkler, Coverage, MSIS, **WAPE, MPE, ACF1, and a directional family
    (MDA / MDV / MDPV)**. The intro lists 6 of them, but no example ever
    scores with one. For a forecasting package, not showing MASE / RMSSE
    at least once is a real gap. The directional measures and WAPE / MPE
    are not even mentioned.

BB: tabelle der measures erstellen bzw verlinken. in den beispielen
sollte auch mal EIN komplexeres zeigen. wenigstens sagen dass die
übersich im R index ist? verlinken? und halt mal ein measure in der
README zeigen.

2.  **Dedicated target-transform pipeops are not mentioned.** The README
    only demonstrates manual `log` / `exp` via the generic
    `ppl("targettrafo")`. But the package exports
    **`PipeOpTargetTrafoBoxCox` (`fcst.targetboxcox`)** and
    **`PipeOpTargetTrafoDifference` (`fcst.targetdiff`)** — Box-Cox and
    differencing are core TS transforms and ship ready-made.

BB: einfach ein satz dass das existiert?

3.  **Data import / IO is entirely absent.** Two exported user-facing
    helpers are unmentioned:
    **[`read_tsf()`](https://mlr3forecast.mlr-org.com/reference/read_tsf.md)**
    (Monash `.tsf` archive format) and
    **[`download_zenodo_record()`](https://mlr3forecast.mlr-org.com/reference/download_zenodo_record.md)**.
    Also
    [`as_task_fcst()`](https://mlr3forecast.mlr-org.com/reference/as_task_fcst.md)
    has methods for `ts`, `zoo`, `timeSeries`, `tsibble` (`tbl_ts`), and
    `tsf` objects — only the data.frame / tsibble paths are shown.

BB: ich denke das müssen wir nicht zeigen? dass ist “ausserhalb” von
mlr3? \# im buch könnte man das mal zeigen? finde ich aktuell nicht
soooo wichtig.

4.  **The learner roster is heavily under-represented.** 34 classical
    learners are exported; the README names ~6. Missing categories worth
    a mention: baselines (`mean`, `random_walk` — matter for the
    benchmarking story), intermittent demand (`croston`), count data
    (`tscount`), neural (`nnetar`, `mlp`, `elm`), and the whole
    `smooth`-package family (`adam`, `ces`, `gum`, `ssarima`,
    `msarima`). No pointer to a full list.

BB: point to full list, mention that we have many / what

5.  **Probabilistic forecasting is shown but never evaluated.** Quantile
    prediction is demonstrated for `auto_arima`, and Pinball / Winkler /
    Coverage / MSIS are listed — but a quantile prediction is never
    scored with them, and it is unclear whether ML forecasters support
    quantiles.

BB: say how you can see whezjer a learner supports this. and use one
measure

6.  **[`as_tasks_fcst()`](https://mlr3forecast.mlr-org.com/reference/as_task_fcst.md)
    (plural, multi-task creation) is unmentioned** — relevant to the
    global / longitudinal story.

**Minor:** `partition()`, [`as.ts()`](https://rdrr.io/r/stats/ts.html),
[`selector_fcst_rolling()`](https://mlr3forecast.mlr-org.com/reference/selector_fcst_rolling.md),
and built-in tasks `lynx` / `livestock` / `usaccdeaths` are not
surfaced.

### Resolution of BB comments (step 3)

All BB-marked comments above were resolved by brief, compact edits to
`README.Rmd` (kept short for a README). Summary:

- **BB \#1 (measures):** Added “see `mlr_measures$keys("^fcst")` for the
  full list” to the at-a-glance measures bullet, and now show a real
  forecasting measure — the classical resampling example aggregates
  `msrs(c("regr.rmse", "fcst.mase"))`.
- **BB \#2 (target-trafo pipeops):** Added one sentence after the ML
  target transformation example noting `po("fcst.targetboxcox")` and
  `po("fcst.targetdiff")` exist.
- **BB \#3 (data IO):** Agreed it is out of scope for the README (more
  of a book topic). No README change.
- **BB \#4 (learner roster):** Reworded the at-a-glance
  classical-forecasters bullet to convey “over 30” learners across
  categories (baselines, ARIMA, neural, count) and point to
  `mlr_learners$keys("^fcst")`.
- **BB \#5 (probabilistic):** Added
  `lrn("fcst.auto_arima")$predict_types` to show how to check supported
  predict types, and score a quantile prediction with
  `msr("fcst.pinball")` on in-sample rows (known truth).
- **Task enumeration (BB at minor):** Added an at-a-glance bullet
  listing the built-in tasks (`airpassengers`, `electricity`,
  `livestock`, `lynx`, `usaccdeaths`) with
  `as.data.table(mlr_tasks)[task_type == "fcst"]`.

Note: `gap #6`
([`as_tasks_fcst()`](https://mlr3forecast.mlr-org.com/reference/as_task_fcst.md))
had no BB mark, so it was left unchanged. `README.Rmd` still needs to be
re-knitted to regenerate `README.md`.

------------------------------------------------------------------------

## 2. API critique

What I would criticize, dislike, or see as obviously improvable in the
public API. These are design observations from reading the source — not
verified by running code. Ordered by impact.

### Higher impact

4.  **MASE / RMSSE default to a non-seasonal naive (`period = 1`) even
    on seasonal tasks.** `R/MeasureScaled.R:35-36,60` — the scaling
    denominator uses `period = 1L` by default and the measure never
    consults `task$freq`. So `msr("fcst.mase")` on monthly airpassengers
    silently uses lag-1 scaling, not the seasonal-naive MASE most users
    expect; they must remember `msr("fcst.mase", period = 12)`. Since
    the task already carries `freq`, the measure could default `period`
    from it. A real footgun — and it now appears in README code (step
    3).

BB: anschauen? mindestens in den docs vor der “footgun” warnen?

### Medium / lower

5.  **Overloaded `lags` argument + recursive/direct asymmetry.**
    `recursive_forecaster(learner, lags = ...)`: if `lags` is given it
    wraps the learner in `po("fcst.lags")`; if `NULL`, `learner` must
    already be a graph (`R/recursive_forecaster.R:13-15`).
    [`direct_forecaster()`](https://mlr3forecast.mlr-org.com/reference/direct_forecaster.md)
    instead *requires* `lags` and additionally `horizons`. “One argument
    silently changes what’s required of another,” plus the asymmetry
    between the two constructors, is mildly surprising.

BB: einfach dokumentieren.

6.  **[`as_task_fcst()`](https://mlr3forecast.mlr-org.com/reference/as_task_fcst.md)
    required arguments differ by input type.** `target` + `order` are
    required for `data.frame` / backend; `target` is inferred for `ts` /
    `zoo` / `tsf`; `order` / `key` are inferred for `tbl_ts`. Somewhat
    inherent to the source formats, but the inconsistency is a learning
    cost and is not summarized anywhere user-facing.

BB: einfach dokumentieren.

7.  **Forecast measures are `task_type = "regr"`, keyed `fcst.*`.** They
    inherit `MeasureRegr`, so
    `as.data.table(mlr_measures)[task_type == "fcst"]` returns nothing —
    discovery only works via the `^fcst` key regex, unlike tasks and
    learners which are genuinely `task_type == "fcst"`. Minor reflection
    inconsistency (and a trap if someone mirrors the task-listing idiom
    for measures).

BB: nochmal ansehen. eigentloch sollten die doch wirklich task_type =
fsct haben (können)? kann man mit leben falls es nicht geht, anders wäre
schöner

9.  **`$model` is a wrapper; the real model is `$native_model`.**
    `LearnerFcst` stores the upstream model inside a list and exposes it
    via `$native_model` (`R/LearnerFcst.R:64-71`), so `$model` is not
    the fitted object as in standard mlr3. Documented, but a surprise
    for code/tooling that expects `$model` to be the model.
    ————————————-

unabhänging von dem was claude hier sagt: flrn\$model gibt genau was
zurück? wenn man das printet kommt da

class(flrn\$model) \[1\] “recursive_forecaster_model” “list”

und dann hat diese klasse nicht mal einen printer. und es kommt ein
langer “schmutz” an members von dem objekt. das “model” ist aber
zentral! hier muss man doch sofort und gut sehen können was das ist?

–\> vielleicht meine frage / vorschlag einfach das hier: a) man weiss
genau (dokumentiert) was hier für eine klasse zurückkommt und was das
ist b) der klasse einen printer geben

------------------------------------------------------------------------

## 3. Larger / structural concerns

Stepping back from individual API points to the big, important things.
These are strategic/architectural, not line-level. Grounded in the
source (deps, tests, the recursive predict loop, the keyed-task guard)
but not run.

### A. No real probabilistic forecasting for the ML (reduction) side

This is, in my view, the single most important gap. Modern forecasting
(M5/M6, industry demand planning) is largely *probabilistic*, and the
package’s own measure set leans that way (Pinball, Winkler, Coverage,
MSIS). Yet:

- **Recursive** multi-step prediction feeds only the point `$response`
  back into the feature matrix at each step (`R/RecursiveForecaster.R`,
  predict loop ~L119-124:
  `set(combined, ..., value = prediction$response)`). There is no
  simulation / bootstrap path, so multi-step predictive *distributions*
  are not propagated — any quantiles you’d get are conditional on point
  estimates of earlier steps and systematically under-dispersed.
- **Direct** could in principle emit per-horizon quantiles if the base
  `regr` learner does, but there is no calibrated-interval machinery
  around it.

Classical wrappers get intervals “for free” from their upstream
packages, which hides the asymmetry: the headline ML story is
effectively point-forecast only. This deserves (a) explicit
documentation of the limitation and (b) a roadmap item for a
simulation/bootstrap-based predictive distribution.

### B. The “forecasting = regr + an order column” abstraction is leaky, and the leaks are runtime-enforced

The reuse story is the package’s biggest strength, but the abstraction
has several sharp, non-obvious exceptions that surface only as runtime
errors:

- Classical `LearnerFcst*` learners **reject keyed (global) tasks**
  (`R/LearnerFcst.R:79-81`, “does not support tasks with keys”). So
  “global forecasting” is an ML-reduction-only capability; with
  classical models you must hand-roll the split/loop (exactly what the
  README’s “local forecasting” example does). That asymmetry is not
  signposted.
- Target-transform pipeops **must not be placed inside** a
  Recursive/Direct graph (`man/mlr_pipeops_fcst.targetboxcox.Rd`,
  Limitations section).
- In-sample and future rows **cannot be mixed** in one
  [`predict()`](https://rdrr.io/r/stats/predict.html)
  (`R/LearnerFcst.R:104-108`).

“Forecasters behave like any other mlr3 learner” is the pitch, but there
are enough composition rules that a capability/property advertisement
(or at least a consolidated “what does *not* compose” doc) is warranted.
Otherwise users discover the boundaries by hitting errors.

### C. Evaluation / backtesting is thin for a forecasting package

Only two resamplings exist (`fcst.holdout`, `fcst.cv`). Missing,
relative to what serious forecasting work expects:

- First-class **rolling-origin evaluation with a per-horizon error
  breakdown** (error-by-h is the standard diagnostic; here you only get
  an aggregate).
- Any **hierarchical / grouped reconciliation** (fable’s core strength).
  Global models exist via keys, but coherent aggregation across a
  hierarchy does not.

This is a fair scope choice for an early package, but it should be
stated explicitly, because it’s the main axis on which users will
compare against `fable`/`fpp3`.

### D. Breadth-over-depth bet: 34 learners across ~10 optional backends

The package wraps a very wide roster (`forecast`, `smooth`, `prophet`,
`tscount`, `nnfor`, `Rlgt`, `Rcatch22`, `feasts`, `tsfeatures`, …; all
in `Suggests`). Each adapter is thin, but collectively this is a large
surface to keep green as upstreams drift, and some backends are heavy
(prophet pulls a Stan toolchain). Worth a deliberate decision: is the
goal *breadth* (wrap everything, accept the maintenance/testing matrix)
or a *clean core + a few exemplars*? Right now it’s breadth, which is a
real long-term commitment — and the per-learner tests (~50
`test_fcst_*.R` files) confirm the cost is already being paid.

### E. No long-form documentation (no vignettes)

There is no `vignettes/` directory; the README is the only narrative
doc. For a package whose *correct* use hinges on subtle ideas —
recursive vs direct, leakage windows, the compose-restrictions in (B),
global vs local, the probabilistic limits in (A) — the absence of
vignettes is a significant adoption and correctness-communication gap. A
pkgdown site is configured, but its long-form content is currently just
the README.

### F. Early-stage maturity vs. the unresolved seams above

`Version: 0.0.1`, lifecycle experimental, not on CRAN, with heuristic
`freq` inference and the API seams in section 2. That’s all fine for the
stage — the point is that the *order* of operations matters: the
structural questions in A–C are the ones that should be settled before
the API ossifies, because fixing them later (e.g. adding a probabilistic
predict path, or a capability system) is much harder once users depend
on the current shapes.
