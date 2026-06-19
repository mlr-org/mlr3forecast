# mlr3forecast — Package Review

A top-down review of the package, with particular attention to the README and
whether it represents the package's functionality. Worked through in small,
discrete steps.

---

## 1. README coverage of functionality

Question: *Does `README.Rmd` display all of the important functionality of the
package?*

Method: compared the features showcased in `README.Rmd` against all exported
objects in `NAMESPACE` (learners, measures, pipeops, resamplings, tasks, and
helper functions).

### What the README covers well

- Classical forecaster workflow: `train` → `predict` → `generate_newdata()` /
  `predict_newdata()` / `forecast()`
- ML forecasting: `recursive_forecaster()` and `direct_forecaster()`
- Temporal resamplings `fcst.holdout` / `fcst.cv`
- Feature engineering via `po("fcst.lags")` + `selector_fcst_lags()`
- Quantile prediction (classical), exogenous covariates, benchmarking,
  ensembling (`po("regravg")`), tuning (`auto_tuner`), and global forecasting

### Notable gaps (advertised or important, but missing / under-shown)

1. **The package's own forecasting measures are never actually used.** Every
   `$score()` call in the README uses `msr("regr.rmse")`. Yet the package ships
   **12** forecasting measures: MASE, RMSSE, Pinball, Winkler, Coverage, MSIS,
   **WAPE, MPE, ACF1, and a directional family (MDA / MDV / MDPV)**. The intro
   lists 6 of them, but no example ever scores with one. For a forecasting
   package, not showing MASE / RMSSE at least once is a real gap. The
   directional measures and WAPE / MPE are not even mentioned.

BB: tabelle der measures erstellen bzw verlinken. in den beispielen sollte auch mal
EIN komplexeres zeigen. wenigstens sagen dass die übersich im R index ist? verlinken?
und halt mal ein measure in der README zeigen.


2. **Dedicated target-transform pipeops are not mentioned.** The README only
   demonstrates manual `log` / `exp` via the generic `ppl("targettrafo")`. But
   the package exports **`PipeOpTargetTrafoBoxCox` (`fcst.targetboxcox`)** and
   **`PipeOpTargetTrafoDifference` (`fcst.targetdiff`)** — Box-Cox and
   differencing are core TS transforms and ship ready-made.

BB: einfach ein satz dass das existiert?

3. **Data import / IO is entirely absent.** Two exported user-facing helpers
   are unmentioned: **`read_tsf()`** (Monash `.tsf` archive format) and
   **`download_zenodo_record()`**. Also `as_task_fcst()` has methods for `ts`,
   `zoo`, `timeSeries`, `tsibble` (`tbl_ts`), and `tsf` objects — only the
   data.frame / tsibble paths are shown.

BB: ich denke das müssen wir nicht zeigen? dass ist "ausserhalb" von mlr3? #
im buch könnte man das mal zeigen? finde ich aktuell nicht soooo wichtig.

4. **The learner roster is heavily under-represented.** 34 classical learners
   are exported; the README names ~6. Missing categories worth a mention:
   baselines (`mean`, `random_walk` — matter for the benchmarking story),
   intermittent demand (`croston`), count data (`tscount`), neural (`nnetar`,
   `mlp`, `elm`), and the whole `smooth`-package family (`adam`, `ces`, `gum`,
   `ssarima`, `msarima`). No pointer to a full list.

BB: point to full list, mention that we have many / what

5. **Probabilistic forecasting is shown but never evaluated.** Quantile
   prediction is demonstrated for `auto_arima`, and Pinball / Winkler /
   Coverage / MSIS are listed — but a quantile prediction is never scored with
   them, and it is unclear whether ML forecasters support quantiles.

BB: say how you can see whezjer a learner supports this. and use one measure

6. **`as_tasks_fcst()` (plural, multi-task creation) is unmentioned** —
   relevant to the global / longitudinal story.

**Minor:** `partition()`, `as.ts()`, `selector_fcst_rolling()`, and built-in
tasks `lynx` / `livestock` / `usaccdeaths` are not surfaced.

### Resolution of BB comments (step 3)

All BB-marked comments above were resolved by brief, compact edits to
`README.Rmd` (kept short for a README). Summary:

- **BB #1 (measures):** Added "see `mlr_measures$keys("^fcst")` for the full
  list" to the at-a-glance measures bullet, and now show a real forecasting
  measure — the classical resampling example aggregates
  `msrs(c("regr.rmse", "fcst.mase"))`.
- **BB #2 (target-trafo pipeops):** Added one sentence after the ML target
  transformation example noting `po("fcst.targetboxcox")` and
  `po("fcst.targetdiff")` exist.
- **BB #3 (data IO):** Agreed it is out of scope for the README (more of a
  book topic). No README change.
- **BB #4 (learner roster):** Reworded the at-a-glance classical-forecasters
  bullet to convey "over 30" learners across categories (baselines, ARIMA,
  neural, count) and point to `mlr_learners$keys("^fcst")`.
- **BB #5 (probabilistic):** Added `lrn("fcst.auto_arima")$predict_types` to
  show how to check supported predict types, and score a quantile prediction
  with `msr("fcst.pinball")` on in-sample rows (known truth).
- **Task enumeration (BB at minor):** Added an at-a-glance bullet listing the
  built-in tasks (`airpassengers`, `electricity`, `livestock`, `lynx`,
  `usaccdeaths`) with `as.data.table(mlr_tasks)[task_type == "fcst"]`.

Note: `gap #6` (`as_tasks_fcst()`) had no BB mark, so it was left unchanged.
`README.Rmd` still needs to be re-knitted to regenerate `README.md`.


BB: enumerate the tasks

