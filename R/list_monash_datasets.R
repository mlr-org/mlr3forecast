# Pinned records from https://forecastingdata.org/, size is the compressed archive size in bytes
# fmt: skip
monash_datasets = rowwise_table(
  ~dataset, ~record_id, ~dataset_name, ~has_missing, ~title, ~size,
  "m1_yearly", 4656193L, "m1_yearly_dataset", FALSE, "M1 Yearly", 13179L,
  "m1_quarterly", 4656154L, "m1_quarterly_dataset", FALSE, "M1 Quarterly", 21290L,
  "m1_monthly", 4656159L, "m1_monthly_dataset", FALSE, "M1 Monthly", 120931L,
  "m3_yearly", 4656222L, "m3_yearly_dataset", FALSE, "M3 Yearly", 50178L,
  "m3_quarterly", 4656262L, "m3_quarterly_dataset", FALSE, "M3 Quarterly", 96124L,
  "m3_monthly", 4656298L, "m3_monthly_dataset", FALSE, "M3 Monthly", 336324L,
  "m3_other", 4656335L, "m3_other_dataset", FALSE, "M3 Other", 33018L,
  "m4_yearly", 4656379L, "m4_yearly_dataset", FALSE, "M4 Yearly", 2785010L,
  "m4_quarterly", 4656410L, "m4_quarterly_dataset", FALSE, "M4 Quarterly", 7031886L,
  "m4_monthly", 4656480L, "m4_monthly_dataset", FALSE, "M4 Monthly", 28235874L,
  "m4_weekly", 4656522L, "m4_weekly_dataset", FALSE, "M4 Weekly", 1077913L,
  "m4_daily", 4656548L, "m4_daily_dataset", FALSE, "M4 Daily", 27963288L,
  "m4_hourly", 4656589L, "m4_hourly_dataset", FALSE, "M4 Hourly", 485448L,
  "tourism_yearly", 4656103L, "tourism_yearly_dataset", FALSE, "Tourism Yearly", 36749L,
  "tourism_quarterly", 4656093L, "tourism_quarterly_dataset", FALSE, "Tourism Quarterly", 93833L,
  "tourism_monthly", 4656096L, "tourism_monthly_dataset", FALSE, "Tourism Monthly", 199791L,
  "cif_2016", 4656042L, "cif_2016_dataset", FALSE, "CIF 2016", 53344L,
  "london_smart_meters_with_missing_values", 4656072L,
  "london_smart_meters_dataset_with_missing_values", TRUE, "London Smart Meters (with Missing Values)", 219673439L,
  "london_smart_meters", 4656091L,
  "london_smart_meters_dataset_without_missing_values", FALSE, "London Smart Meters", 219651092L,
  "australian_electricity_demand", 4659727L,
  "australian_electricity_demand_dataset", FALSE, "Australian Electricity Demand", 5770526L,
  "elecdemand", 4656069L, "elecdemand_dataset", FALSE, "Electricity Demand", 89963L,
  "wind_farms_minutely_with_missing_values", 4654909L,
  "wind_farms_minutely_dataset_with_missing_values", TRUE, "Wind Farms Minutely (with Missing Values)", 71383130L,
  "wind_farms_minutely", 4654858L,
  "wind_farms_minutely_dataset_without_missing_values", FALSE, "Wind Farms Minutely", 71369048L,
  "dominick", 4654802L, "dominick_dataset", FALSE, "Dominick", 12328941L,
  "bitcoin_with_missing_values", 5121965L,
  "bitcoin_dataset_with_missing_values", TRUE, "Bitcoin (with Missing Values)", 220403L,
  "bitcoin", 5122101L, "bitcoin_dataset_without_missing_values", FALSE, "Bitcoin", 220635L,
  "pedestrian_counts", 4656626L, "pedestrian_counts_dataset", FALSE, "Melbourne Pedestrian Counts", 4587054L,
  "vehicle_trips_with_missing_values", 5122535L,
  "vehicle_trips_dataset_with_missing_values", TRUE, "Vehicle Trips (with Missing Values)", 44914L,
  "vehicle_trips", 5122537L, "vehicle_trips_dataset_without_missing_values", FALSE, "Vehicle Trips", 44452L,
  "kdd_cup_2018_with_missing_values", 4656719L,
  "kdd_cup_2018_dataset_with_missing_values", TRUE, "KDD Cup 2018 (with Missing Values)", 2456948L,
  "kdd_cup_2018", 4656756L, "kdd_cup_2018_dataset_without_missing_values", FALSE, "KDD Cup 2018", 2432429L,
  "weather", 4654822L, "weather_dataset", FALSE, "Weather", 38820451L,
  "nn5_daily_with_missing_values", 4656110L,
  "nn5_daily_dataset_with_missing_values", TRUE, "NN5 Daily (with Missing Values)", 287708L,
  "nn5_daily", 4656117L, "nn5_daily_dataset_without_missing_values", FALSE, "NN5 Daily", 289779L,
  "nn5_weekly", 4656125L, "nn5_weekly_dataset", FALSE, "NN5 Weekly", 62043L,
  "kaggle_web_traffic_with_missing_values", 4656080L, "kaggle_web_traffic_dataset_with_missing_values",
  TRUE, "Kaggle Wikipedia Web Traffic Daily (with Missing Values)", 145485324L,
  "kaggle_web_traffic", 4656075L,
  "kaggle_web_traffic_dataset_without_missing_values", FALSE, "Kaggle Wikipedia Web Traffic Daily", 145140849L,
  "kaggle_web_traffic_weekly", 4656664L,
  "kaggle_web_traffic_weekly_dataset", FALSE, "Kaggle Wikipedia Web Traffic Weekly", 28930900L,
  "solar_10_minutes", 4656144L, "solar_10_minutes_dataset", FALSE, "Solar 10 Minutes", 4559353L,
  "solar_weekly", 4656151L, "solar_weekly_dataset", FALSE, "Solar Weekly", 24375L,
  "electricity_hourly", 4656140L, "electricity_hourly_dataset", FALSE, "Electricity Hourly", 11823931L,
  "electricity_weekly", 4656141L, "electricity_weekly_dataset", FALSE, "Electricity Weekly", 147816L,
  "car_parts_with_missing_values", 4656022L,
  "car_parts_dataset_with_missing_values", TRUE, "Car Parts (with Missing Values)", 39656L,
  "car_parts", 4656021L, "car_parts_dataset_without_missing_values", FALSE, "Car Parts", 39609L,
  "fred_md", 4654833L, "fred_md_dataset", FALSE, "FRED-MD", 169107L,
  "traffic_hourly", 4656132L, "traffic_hourly_dataset", FALSE, "Traffic Hourly", 22868806L,
  "traffic_weekly", 4656135L, "traffic_weekly_dataset", FALSE, "Traffic Weekly", 245126L,
  "rideshare_with_missing_values", 5122114L,
  "rideshare_dataset_with_missing_values", TRUE, "Rideshare (with Missing Values)", 1031826L,
  "rideshare", 5122232L, "rideshare_dataset_without_missing_values", FALSE, "Rideshare", 1073443L,
  "hospital", 4656014L, "hospital_dataset", FALSE, "Hospital", 78110L,
  "covid_deaths", 4656009L, "covid_deaths_dataset", FALSE, "COVID-19 Deaths", 27335L,
  "temperature_rain_with_missing_values", 5129073L,
  "temperature_rain_dataset_with_missing_values", TRUE, "Temperature Rain (with Missing Values)", 25747139L,
  "temperature_rain", 5129091L, "temperature_rain_dataset_without_missing_values", FALSE, "Temperature Rain", 25201952L,
  "sunspot_with_missing_values", 4654773L,
  "sunspot_dataset_with_missing_values", TRUE, "Sunspot Daily (with Missing Values)", 68865L,
  "sunspot", 4654722L, "sunspot_dataset_without_missing_values", FALSE, "Sunspot Daily", 68476L,
  "saugeenday", 4656058L, "saugeenday_dataset", FALSE, "Saugeen River Flow", 28721L,
  "us_births", 4656049L, "us_births_dataset", FALSE, "US Births", 16332L,
  "solar_4_seconds", 4656027L, "solar_4_seconds_dataset", FALSE, "Solar Power 4 Seconds", 794502L,
  "wind_4_seconds", 4656032L, "wind_4_seconds_dataset", FALSE, "Wind Power 4 Seconds", 2226184L
)

#' @title List Monash Forecasting Repository datasets
#'
#' @description
#' Lists the datasets of the Monash Forecasting Repository that [download_monash_dataset()] can retrieve.
#' Datasets with `has_missing = FALSE` can also be loaded as a forecast task with `tsk("monash", dataset = )`.
#'
#' @return ([data.table::data.table()]) with one row per dataset and the columns `dataset` (the dataset ID),
#'   `title`, `has_missing` (whether the series contain missing values), `size` (the size of the compressed
#'   archive in bytes), `record_id` (the Zenodo record ID), and `dataset_name` (the name of the Zenodo file without
#'   the `".zip"` extension).
#'
#' @references
#' `r format_bib("godahewa2021monash")`
#'
#' @export
#' @examples
#' datasets = list_monash_datasets()
#' head(datasets)
#' datasets[(!has_missing), dataset]
list_monash_datasets = function() {
  out = copy(monash_datasets)
  setcolorder(out, c("dataset", "title", "has_missing", "size"))[]
}

resolve_monash_dataset = function(dataset) {
  assert_string(dataset, min.chars = 1L)
  if (dataset %nin% monash_datasets$dataset) {
    error_input(
      "Unknown Monash dataset '%s'.%s See list_monash_datasets() for the available IDs.",
      dataset,
      did_you_mean(dataset, monash_datasets$dataset)
    )
  }
  monash_datasets[dataset, on = "dataset"]
}
