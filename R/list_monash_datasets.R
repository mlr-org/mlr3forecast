# Pinned records from https://forecastingdata.org/
# fmt: skip
monash_datasets = rowwise_table(
  ~dataset, ~title, ~has_missing, ~record_id, ~dataset_name,
  "m1_yearly", "M1 Yearly", FALSE, 4656193L, "m1_yearly_dataset",
  "m1_quarterly", "M1 Quarterly", FALSE, 4656154L, "m1_quarterly_dataset",
  "m1_monthly", "M1 Monthly", FALSE, 4656159L, "m1_monthly_dataset",
  "m3_yearly", "M3 Yearly", FALSE, 4656222L, "m3_yearly_dataset",
  "m3_quarterly", "M3 Quarterly", FALSE, 4656262L, "m3_quarterly_dataset",
  "m3_monthly", "M3 Monthly", FALSE, 4656298L, "m3_monthly_dataset",
  "m3_other", "M3 Other", FALSE, 4656335L, "m3_other_dataset",
  "m4_yearly", "M4 Yearly", FALSE, 4656379L, "m4_yearly_dataset",
  "m4_quarterly", "M4 Quarterly", FALSE, 4656410L, "m4_quarterly_dataset",
  "m4_monthly", "M4 Monthly", FALSE, 4656480L, "m4_monthly_dataset",
  "m4_weekly", "M4 Weekly", FALSE, 4656522L, "m4_weekly_dataset",
  "m4_daily", "M4 Daily", FALSE, 4656548L, "m4_daily_dataset",
  "m4_hourly", "M4 Hourly", FALSE, 4656589L, "m4_hourly_dataset",
  "tourism_yearly", "Tourism Yearly", FALSE, 4656103L, "tourism_yearly_dataset",
  "tourism_quarterly", "Tourism Quarterly", FALSE, 4656093L, "tourism_quarterly_dataset",
  "tourism_monthly", "Tourism Monthly", FALSE, 4656096L, "tourism_monthly_dataset",
  "cif_2016", "CIF 2016", FALSE, 4656042L, "cif_2016_dataset",
  "london_smart_meters_with_missing_values", "London Smart Meters (with Missing Values)", TRUE, 4656072L,
  "london_smart_meters_dataset_with_missing_values",
  "london_smart_meters", "London Smart Meters", FALSE, 4656091L, "london_smart_meters_dataset_without_missing_values",
  "australian_electricity_demand", "Australian Electricity Demand", FALSE, 4659727L,
  "australian_electricity_demand_dataset",
  "elecdemand", "Electricity Demand", FALSE, 4656069L, "elecdemand_dataset",
  "wind_farms_minutely_with_missing_values", "Wind Farms Minutely (with Missing Values)", TRUE, 4654909L,
  "wind_farms_minutely_dataset_with_missing_values",
  "wind_farms_minutely", "Wind Farms Minutely", FALSE, 4654858L, "wind_farms_minutely_dataset_without_missing_values",
  "dominick", "Dominick", FALSE, 4654802L, "dominick_dataset",
  "bitcoin_with_missing_values", "Bitcoin (with Missing Values)", TRUE, 5121965L, "bitcoin_dataset_with_missing_values",
  "bitcoin", "Bitcoin", FALSE, 5122101L, "bitcoin_dataset_without_missing_values",
  "pedestrian_counts", "Melbourne Pedestrian Counts", FALSE, 4656626L, "pedestrian_counts_dataset",
  "vehicle_trips_with_missing_values", "Vehicle Trips (with Missing Values)", TRUE, 5122535L,
  "vehicle_trips_dataset_with_missing_values",
  "vehicle_trips", "Vehicle Trips", FALSE, 5122537L, "vehicle_trips_dataset_without_missing_values",
  "kdd_cup_2018_with_missing_values", "KDD Cup 2018 (with Missing Values)", TRUE, 4656719L,
  "kdd_cup_2018_dataset_with_missing_values",
  "kdd_cup_2018", "KDD Cup 2018", FALSE, 4656756L, "kdd_cup_2018_dataset_without_missing_values",
  "weather", "Weather", FALSE, 4654822L, "weather_dataset",
  "nn5_daily_with_missing_values", "NN5 Daily (with Missing Values)", TRUE, 4656110L,
  "nn5_daily_dataset_with_missing_values",
  "nn5_daily", "NN5 Daily", FALSE, 4656117L, "nn5_daily_dataset_without_missing_values",
  "nn5_weekly", "NN5 Weekly", FALSE, 4656125L, "nn5_weekly_dataset",
  "kaggle_web_traffic_with_missing_values", "Kaggle Wikipedia Web Traffic Daily (with Missing Values)", TRUE, 4656080L,
  "kaggle_web_traffic_dataset_with_missing_values",
  "kaggle_web_traffic", "Kaggle Wikipedia Web Traffic Daily", FALSE, 4656075L,
  "kaggle_web_traffic_dataset_without_missing_values",
  "kaggle_web_traffic_weekly", "Kaggle Wikipedia Web Traffic Weekly", FALSE, 4656664L,
  "kaggle_web_traffic_weekly_dataset",
  "solar_10_minutes", "Solar 10 Minutes", FALSE, 4656144L, "solar_10_minutes_dataset",
  "solar_weekly", "Solar Weekly", FALSE, 4656151L, "solar_weekly_dataset",
  "electricity_hourly", "Electricity Hourly", FALSE, 4656140L, "electricity_hourly_dataset",
  "electricity_weekly", "Electricity Weekly", FALSE, 4656141L, "electricity_weekly_dataset",
  "car_parts_with_missing_values", "Car Parts (with Missing Values)", TRUE, 4656022L,
  "car_parts_dataset_with_missing_values",
  "car_parts", "Car Parts", FALSE, 4656021L, "car_parts_dataset_without_missing_values",
  "fred_md", "FRED-MD", FALSE, 4654833L, "fred_md_dataset",
  "traffic_hourly", "Traffic Hourly", FALSE, 4656132L, "traffic_hourly_dataset",
  "traffic_weekly", "Traffic Weekly", FALSE, 4656135L, "traffic_weekly_dataset",
  "rideshare_with_missing_values", "Rideshare (with Missing Values)", TRUE, 5122114L,
  "rideshare_dataset_with_missing_values",
  "rideshare", "Rideshare", FALSE, 5122232L, "rideshare_dataset_without_missing_values",
  "hospital", "Hospital", FALSE, 4656014L, "hospital_dataset",
  "covid_deaths", "COVID-19 Deaths", FALSE, 4656009L, "covid_deaths_dataset",
  "temperature_rain_with_missing_values", "Temperature Rain (with Missing Values)", TRUE, 5129073L,
  "temperature_rain_dataset_with_missing_values",
  "temperature_rain", "Temperature Rain", FALSE, 5129091L, "temperature_rain_dataset_without_missing_values",
  "sunspot_with_missing_values", "Sunspot Daily (with Missing Values)", TRUE, 4654773L,
  "sunspot_dataset_with_missing_values",
  "sunspot", "Sunspot Daily", FALSE, 4654722L, "sunspot_dataset_without_missing_values",
  "saugeenday", "Saugeen River Flow", FALSE, 4656058L, "saugeenday_dataset",
  "us_births", "US Births", FALSE, 4656049L, "us_births_dataset",
  "solar_4_seconds", "Solar Power 4 Seconds", FALSE, 4656027L, "solar_4_seconds_dataset",
  "wind_4_seconds", "Wind Power 4 Seconds", FALSE, 4656032L, "wind_4_seconds_dataset"
)

#' @title List Monash Forecasting Repository datasets
#'
#' @description
#' Lists the datasets of the Monash Forecasting Repository that [download_monash_dataset()] can retrieve.
#' Datasets with `has_missing = FALSE` can also be loaded as a forecast task with `tsk("monash", dataset = )`.
#'
#' @return ([data.table::data.table()]) with one row per dataset and the columns `dataset` (the dataset ID),
#'   `title`, `has_missing` (whether the series contain missing values), `record_id` (the Zenodo record ID),
#'   and `dataset_name` (the name of the Zenodo file).
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
  dataset = NULL
  monash_datasets[order(dataset)]
}

resolve_monash_dataset = function(dataset) {
  assert_choice(dataset, monash_datasets$dataset)
  monash_datasets[dataset, on = "dataset"]
}
