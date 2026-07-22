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
file = system.file("extdata", "m3_yearly_dataset.tsf", package = "mlr3forecast")
dt = read_tsf(file)
#> Reading tsf file:
#> • frequency: yearly
#> • horizon: 6
head(dt)
#>    series_name start_timestamp   value
#>         <char>          <Date>   <num>
#> 1:          T1      1975-01-01  940.66
#> 2:          T1      1976-01-01 1084.86
#> 3:          T1      1977-01-01 1244.98
#> 4:          T1      1978-01-01 1445.02
#> 5:          T1      1979-01-01 1683.17
#> 6:          T1      1980-01-01 2038.15
```
