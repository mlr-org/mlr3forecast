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
with class `"tsf"`. If the file contains a frequency, the `"frequency"`
attribute is set.

## References

Godahewa, Rakshitha, Bergmeir, Christoph, Webb, I G, Hyndman, J R,
Montero-Manso, Pablo (2021). “Monash time series forecasting archive.”
*arXiv preprint arXiv:2105.06643*.

## Examples

``` r
if (FALSE) { # \dontrun{
dt = read_tsf("path/to/file.tsf")
} # }
```
