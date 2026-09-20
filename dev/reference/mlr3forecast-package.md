# mlr3forecast: Extending 'mlr3' to Time Series Forecasting

Extends the 'mlr3' package and ecosystem to time series forecasting.
Provides forecasting tasks, learners, resampling strategies, performance
measures, and 'mlr3pipelines' operators for time-series feature
engineering. Machine learning regression learners can be turned into
forecasters through recursive and direct multi-step strategies.

## Options

- `mlr3forecast.cache`: Enables or disables caching of downloaded
  datasets. If set to `FALSE`, caching is disabled. If set to `TRUE`,
  the cache directory as reported by
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html) is used.
  Alternatively, you can specify a path on the local file system here.
  Default is `FALSE`.

## See also

Useful links:

- <https://mlr3forecast.mlr-org.com>

- <https://github.com/mlr-org/mlr3forecast>

- Report bugs at <https://github.com/mlr-org/mlr3forecast/issues>

## Author

**Maintainer**: Maximilian Mücke <muecke.maximilian@gmail.com>
([ORCID](https://orcid.org/0009-0000-9432-9795))

Authors:

- Maximilian Mücke <muecke.maximilian@gmail.com>
  ([ORCID](https://orcid.org/0009-0000-9432-9795))

- Marc Becker <marcbecker@posteo.de>
  ([ORCID](https://orcid.org/0000-0002-8115-0400))

- Bernd Bischl <bernd.bischl@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-6002-6980))
