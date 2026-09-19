# Pinned records from https://forecastingdata.org/
# fmt: skip
monash_datasets = rowwise_table(
  ~dataset, ~record_id, ~dataset_name, ~has_missing, ~title,
  "m1_yearly", 4656193L, "m1_yearly_dataset", FALSE, "M1 Yearly",
  "m1_quarterly", 4656154L, "m1_quarterly_dataset", FALSE, "M1 Quarterly",
  "m1_monthly", 4656159L, "m1_monthly_dataset", FALSE, "M1 Monthly",
  "m3_yearly", 4656222L, "m3_yearly_dataset", FALSE, "M3 Yearly",
  "m3_quarterly", 4656262L, "m3_quarterly_dataset", FALSE, "M3 Quarterly",
  "m3_monthly", 4656298L, "m3_monthly_dataset", FALSE, "M3 Monthly",
  "m3_other", 4656335L, "m3_other_dataset", FALSE, "M3 Other",
  "m4_yearly", 4656379L, "m4_yearly_dataset", FALSE, "M4 Yearly",
  "m4_quarterly", 4656410L, "m4_quarterly_dataset", FALSE, "M4 Quarterly",
  "m4_monthly", 4656480L, "m4_monthly_dataset", FALSE, "M4 Monthly",
  "m4_weekly", 4656522L, "m4_weekly_dataset", FALSE, "M4 Weekly",
  "m4_daily", 4656548L, "m4_daily_dataset", FALSE, "M4 Daily",
  "m4_hourly", 4656589L, "m4_hourly_dataset", FALSE, "M4 Hourly",
  "tourism_yearly", 4656103L, "tourism_yearly_dataset", FALSE, "Tourism Yearly",
  "tourism_quarterly", 4656093L, "tourism_quarterly_dataset", FALSE, "Tourism Quarterly",
  "tourism_monthly", 4656096L, "tourism_monthly_dataset", FALSE, "Tourism Monthly",
  "cif_2016", 4656042L, "cif_2016_dataset", FALSE, "CIF 2016",
  "london_smart_meters_with_missing_values", 4656072L,
  "london_smart_meters_dataset_with_missing_values", TRUE, "London Smart Meters (with Missing Values)",
  "london_smart_meters", 4656091L, "london_smart_meters_dataset_without_missing_values", FALSE, "London Smart Meters",
  "australian_electricity_demand", 4659727L,
  "australian_electricity_demand_dataset", FALSE, "Australian Electricity Demand",
  "elecdemand", 4656069L, "elecdemand_dataset", FALSE, "Electricity Demand",
  "wind_farms_minutely_with_missing_values", 4654909L,
  "wind_farms_minutely_dataset_with_missing_values", TRUE, "Wind Farms Minutely (with Missing Values)",
  "wind_farms_minutely", 4654858L, "wind_farms_minutely_dataset_without_missing_values", FALSE, "Wind Farms Minutely",
  "dominick", 4654802L, "dominick_dataset", FALSE, "Dominick",
  "bitcoin_with_missing_values", 5121965L, "bitcoin_dataset_with_missing_values", TRUE, "Bitcoin (with Missing Values)",
  "bitcoin", 5122101L, "bitcoin_dataset_without_missing_values", FALSE, "Bitcoin",
  "pedestrian_counts", 4656626L, "pedestrian_counts_dataset", FALSE, "Melbourne Pedestrian Counts",
  "vehicle_trips_with_missing_values", 5122535L,
  "vehicle_trips_dataset_with_missing_values", TRUE, "Vehicle Trips (with Missing Values)",
  "vehicle_trips", 5122537L, "vehicle_trips_dataset_without_missing_values", FALSE, "Vehicle Trips",
  "kdd_cup_2018_with_missing_values", 4656719L,
  "kdd_cup_2018_dataset_with_missing_values", TRUE, "KDD Cup 2018 (with Missing Values)",
  "kdd_cup_2018", 4656756L, "kdd_cup_2018_dataset_without_missing_values", FALSE, "KDD Cup 2018",
  "weather", 4654822L, "weather_dataset", FALSE, "Weather",
  "nn5_daily_with_missing_values", 4656110L,
  "nn5_daily_dataset_with_missing_values", TRUE, "NN5 Daily (with Missing Values)",
  "nn5_daily", 4656117L, "nn5_daily_dataset_without_missing_values", FALSE, "NN5 Daily",
  "nn5_weekly", 4656125L, "nn5_weekly_dataset", FALSE, "NN5 Weekly",
  "kaggle_web_traffic_with_missing_values", 4656080L,
  "kaggle_web_traffic_dataset_with_missing_values", TRUE, "Kaggle Wikipedia Web Traffic Daily (with Missing Values)",
  "kaggle_web_traffic", 4656075L,
  "kaggle_web_traffic_dataset_without_missing_values", FALSE, "Kaggle Wikipedia Web Traffic Daily",
  "kaggle_web_traffic_weekly", 4656664L,
  "kaggle_web_traffic_weekly_dataset", FALSE, "Kaggle Wikipedia Web Traffic Weekly",
  "solar_10_minutes", 4656144L, "solar_10_minutes_dataset", FALSE, "Solar 10 Minutes",
  "solar_weekly", 4656151L, "solar_weekly_dataset", FALSE, "Solar Weekly",
  "electricity_hourly", 4656140L, "electricity_hourly_dataset", FALSE, "Electricity Hourly",
  "electricity_weekly", 4656141L, "electricity_weekly_dataset", FALSE, "Electricity Weekly",
  "car_parts_with_missing_values", 4656022L,
  "car_parts_dataset_with_missing_values", TRUE, "Car Parts (with Missing Values)",
  "car_parts", 4656021L, "car_parts_dataset_without_missing_values", FALSE, "Car Parts",
  "fred_md", 4654833L, "fred_md_dataset", FALSE, "FRED-MD",
  "traffic_hourly", 4656132L, "traffic_hourly_dataset", FALSE, "Traffic Hourly",
  "traffic_weekly", 4656135L, "traffic_weekly_dataset", FALSE, "Traffic Weekly",
  "rideshare_with_missing_values", 5122114L,
  "rideshare_dataset_with_missing_values", TRUE, "Rideshare (with Missing Values)",
  "rideshare", 5122232L, "rideshare_dataset_without_missing_values", FALSE, "Rideshare",
  "hospital", 4656014L, "hospital_dataset", FALSE, "Hospital",
  "covid_deaths", 4656009L, "covid_deaths_dataset", FALSE, "COVID-19 Deaths",
  "temperature_rain_with_missing_values", 5129073L,
  "temperature_rain_dataset_with_missing_values", TRUE, "Temperature Rain (with Missing Values)",
  "temperature_rain", 5129091L, "temperature_rain_dataset_without_missing_values", FALSE, "Temperature Rain",
  "sunspot_with_missing_values", 4654773L,
  "sunspot_dataset_with_missing_values", TRUE, "Sunspot Daily (with Missing Values)",
  "sunspot", 4654722L, "sunspot_dataset_without_missing_values", FALSE, "Sunspot Daily",
  "saugeenday", 4656058L, "saugeenday_dataset", FALSE, "Saugeen River Flow",
  "us_births", 4656049L, "us_births_dataset", FALSE, "US Births",
  "solar_4_seconds", 4656027L, "solar_4_seconds_dataset", FALSE, "Solar Power 4 Seconds",
  "wind_4_seconds", 4656032L, "wind_4_seconds_dataset", FALSE, "Wind Power 4 Seconds"
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
  out = copy(monash_datasets)
  setcolorder(out, c("dataset", "title", "has_missing"))[]
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
