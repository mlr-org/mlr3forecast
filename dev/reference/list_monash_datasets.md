# List Monash Forecasting Repository datasets

Lists the datasets of the Monash Forecasting Repository that
[`download_monash_dataset()`](https://mlr3forecast.mlr-org.com/dev/reference/download_monash_dataset.md)
can retrieve. Datasets with `has_missing = FALSE` can also be loaded as
a forecast task with `tsk("monash", dataset = )`.

## Usage

``` r
list_monash_datasets()
```

## Value

([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))
with one row per dataset and the columns `dataset` (the dataset ID),
`title`, `has_missing` (whether the series contain missing values),
`size` (the size of the compressed archive in bytes), `record_id` (the
Zenodo record ID), and `file` (the name of the Zenodo file).

## References

Godahewa R, Bergmeir C, Webb GI, Hyndman RJ, Montero-Manso P (2021).
“Monash time series forecasting archive.” *arXiv preprint
arXiv:2105.06643*.

## Examples

``` r
datasets = list_monash_datasets()
head(datasets)
#>         dataset        title has_missing   size record_id
#>          <char>       <char>      <lgcl>  <int>     <int>
#> 1:    m1_yearly    M1 Yearly       FALSE  13179   4656193
#> 2: m1_quarterly M1 Quarterly       FALSE  21290   4656154
#> 3:   m1_monthly   M1 Monthly       FALSE 120931   4656159
#> 4:    m3_yearly    M3 Yearly       FALSE  50178   4656222
#> 5: m3_quarterly M3 Quarterly       FALSE  96124   4656262
#> 6:   m3_monthly   M3 Monthly       FALSE 336324   4656298
#>                        file
#>                      <char>
#> 1:    m1_yearly_dataset.zip
#> 2: m1_quarterly_dataset.zip
#> 3:   m1_monthly_dataset.zip
#> 4:    m3_yearly_dataset.zip
#> 5: m3_quarterly_dataset.zip
#> 6:   m3_monthly_dataset.zip
datasets[(!has_missing), dataset]
#>  [1] "m1_yearly"                     "m1_quarterly"                 
#>  [3] "m1_monthly"                    "m3_yearly"                    
#>  [5] "m3_quarterly"                  "m3_monthly"                   
#>  [7] "m3_other"                      "m4_yearly"                    
#>  [9] "m4_quarterly"                  "m4_monthly"                   
#> [11] "m4_weekly"                     "m4_daily"                     
#> [13] "m4_hourly"                     "tourism_yearly"               
#> [15] "tourism_quarterly"             "tourism_monthly"              
#> [17] "cif_2016"                      "london_smart_meters"          
#> [19] "australian_electricity_demand" "elecdemand"                   
#> [21] "wind_farms_minutely"           "dominick"                     
#> [23] "bitcoin"                       "pedestrian_counts"            
#> [25] "vehicle_trips"                 "kdd_cup_2018"                 
#> [27] "weather"                       "nn5_daily"                    
#> [29] "nn5_weekly"                    "kaggle_web_traffic"           
#> [31] "kaggle_web_traffic_weekly"     "solar_10_minutes"             
#> [33] "solar_weekly"                  "electricity_hourly"           
#> [35] "electricity_weekly"            "car_parts"                    
#> [37] "fred_md"                       "traffic_hourly"               
#> [39] "traffic_weekly"                "rideshare"                    
#> [41] "hospital"                      "covid_deaths"                 
#> [43] "temperature_rain"              "sunspot"                      
#> [45] "saugeenday"                    "us_births"                    
#> [47] "solar_4_seconds"               "wind_4_seconds"               
```
