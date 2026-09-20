# Download tsf file from Zenodo

Deprecated, use
[`download_monash_dataset()`](https://mlr3forecast.mlr-org.com/dev/reference/download_monash_dataset.md)
instead. Downloads a tsf file from Zenodo using a Zenodo record ID and
file name.

## Usage

``` r
download_zenodo_record(record_id, dataset_name)
```

## Arguments

- record_id:

  (`integer(1)`)  
  The Zenodo record ID, e.g. `4656222` for the M3 yearly dataset.

- dataset_name:

  (`character(1)`)  
  The name of the Zenodo file without the `".zip"` extension, e.g.
  `"m3_yearly_dataset"`.

## Value

([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))
with class `"tsf"`, see
[`download_monash_dataset()`](https://mlr3forecast.mlr-org.com/dev/reference/download_monash_dataset.md).
