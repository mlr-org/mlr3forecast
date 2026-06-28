# Read tsf files

Parses a file located at `file` and returns a
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html).

## Usage

``` r
read_tsf(file)
```

## Arguments

- file:

  (`character(1)`)  
  The path to the TSF file.

## Value

([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))
with class `"tsf"`. If the file contains a frequency or horizon, the
`"frequency"` and `"horizon"` attributes are set, respectively.

## References

Godahewa R, Bergmeir C, Webb GI, Hyndman RJ, Montero-Manso P (2021).
“Monash time series forecasting archive.” *arXiv preprint
arXiv:2105.06643*.

## Examples

``` r
if (FALSE) { # \dontrun{
dt = read_tsf("path/to/file.tsf")
} # }
```
