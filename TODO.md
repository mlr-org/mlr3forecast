# TODO

## Measures

- [ ] Optimize `score_grouped()` for pointwise measures (MAE, MASE, RMSSE, Coverage, Winkler, MPE) using data.table `by` grouping instead of the current split + clone approach. Benchmark shows ~18x speedup and ~22x less memory at 100 series. Sequential measures (ACF1, MDA, MDV, MDPV) still need the split path since they require the full series for `diff()` / `acf()`.
