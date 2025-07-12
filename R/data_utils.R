library(readr)
library(dplyr)
library(janitor)
library(lubridate)
library(purrr)

#' Reads all files in a given directory
#'
#' This function takes in a directory, and returns a tibble from the concatenated data in that directory.
#'
#' @param directory The directory to grab files from
#' @returns A tibble composed of all data from the given directory
#' @examples
#' read_files("data")
read_files <- function(directory) {
  all_files <- list.files(directory, full.names = TRUE)
  df <- readr::read_csv(all_files, show_col_types = FALSE)

  return(df)
}


#' Performs any necessary preprocessing on a dataframe
#'
#' @description
#' This function takes in a dataframe and preprocesses it for further analysis.
#' The names are cleaned for a consistent column naming format and date has been replaced with year/month/day columns
#'
#' @param df The tibble dataframe to clean
#' @returns A preprocessed tibble dataframe
clean_df <- function(df) {
  clean_df <- df |>
    janitor::clean_names("upper_camel") |>
    dplyr::mutate(
      Month = lubridate::month(Date),
      Year = lubridate::year(Date),
      Day = lubridate::day(Date)
    )

  return(clean_df)
}

#' Returns average monthly price for settlement points
#'
#' For each hub and load zone, computes the mean price for each month in the dataset
compute_average_price <- function(df) {
  average_df <- df |>
    dplyr::group_by(Year, Month, SettlementPoint) |>
    dplyr::summarize(AveragePrice = mean(Price), .groups = "drop") |>

    # Reorder the columns to work with CSV format
    dplyr::relocate(c(SettlementPoint, Year, Month, AveragePrice))

  return(average_df)
}

#' Computes the hourly volatility for each settlement point and year
#'
#' Taking in a tibble dataframe of hourly power prices, this function calculates the volatility
#' for each settlement hub over each year. Hourly volatility is defined as the standard deviation
#' of the log returns, which is calculated below
#'
#' @param df The dataframe containing the power data
#' @returns A dataframe of the shape SettlementPoint x Year x HourlyVolatility
compute_hourly_volatility <- function(df) {
  hourly_volatility_df <- df |>
    # This will cause a 1 hour gap in some of the data points, however it is infrequent
    # enough that it should not cause long term issues
    dplyr::filter(stringr::str_starts(SettlementPoint, "HB") & Price > 0) |>

    # Make sure data is arranged in order of date for this to work
    dplyr::arrange(Date) |>

    # Group into each hub and calculate the log returns
    dplyr::group_by(SettlementPoint) |>
    dplyr::mutate(
      LagPrice = dplyr::lag(Price),
      Return = Price / LagPrice,
      LogReturn = log(Return)
    ) |>

    # Finally, group by the variables of interest and calculate the volatility
    dplyr::group_by(Year, SettlementPoint) |>
    dplyr::summarize(
      HourlyVolatility = sd(LogReturn, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::relocate(SettlementPoint, Year, HourlyVolatility)

  return(hourly_volatility_df)
}

#' Computes which settlement hub had the highest volatility per year
#'
#' Uses the slice_max function to compute the "top-ranking" settlement hub per year
#' by hourly volatility
#'
#' @param volatility_df The dataframe of hourly volatility that should be computed by the
#' "compute_hourly_volatility" function
#' @returns A tibble of the shape SettlementPoint x Year x HourlyVolatility
compute_highest_volatility_per_year <- function(volatility_df) {
  return(hourly_volatility_df |> dplyr::slice_max(HourlyVolatility, by = Year))
}

#' Splits a dataframe up into a list of settlements
#'
#' First, this function takes each distinct hour and transforms it into a unique column
#' Then, the function creates a separate dataframe for each settlement point
#' and returns a list of those dataframes
#'
#' @param df The dataframe to split
#' @returns A list of tibbles, one for each settlement point, in the shape
#' SettlementPoint x Date x X1..X2..X3....X24 (one for each hour)
split_df_into_settlements <- function(df) {
  settlement_split <- df |>
    # Add an hour to account for cQuant hourly variables starting at 1
    dplyr::mutate(Hour = lubridate::hour(Date) + 1) |>

    # Actually take each hour and create a separate column for that hour
    tidyr::pivot_wider(
      names_from = Hour,
      values_from = Price,
      names_prefix = "X",
      id_cols = c(Month, Year, Day, SettlementPoint)
    ) |>

    # Retrieve the date from the year/month/day and drop all unnecessary columns
    dplyr::mutate(Date = lubridate::make_date(Year, Month, Day)) |>
    dplyr::select(SettlementPoint, Date, X1:X24) |>

    # Can never be too careful
    dplyr::arrange(SettlementPoint, Date) |>

    # Group into settlements and split into a list of each settlement point
    dplyr::group_by(SettlementPoint) |>
    dplyr::group_split()

  return(settlement_split)
}

#' Takes a dataframe for a single settlement and writes it to file
#'
#' Assuming this dataframe has been processed to only focus on a single settlement point
#' this function will determine its filename and write it to disk
#'
#' @param df A tibble dataframe that has data for a single settlement, formatted in cQuant fashion
write_cQuant_file <- function(df) {
  # First, extract the settlement point name
  settlementPoint <- as.character(unique(df["SettlementPoint"]))

  # Then, create the filename
  filename = paste(
    c(
      "output/formattedSpotHistory/spot_",
      settlementPoint,
      ".csv"
    ),
    collapse = ""
  )

  # Finally, write the CSV
  readr::write_csv(df, filename)
}

#' Formats the files according to cQuant specifications, and writes to disk
#'
#' Uses split_df_into_settlements to obtain a list of formatted dataframes, then
#' uses purrr (functional programming!) to write each dataframe to disk
#'
#' @param df A cleaned tibble dataframe containing hourly price data for all settlement points
format_and_write_cQuant_files <- function(df) {
  split_settlements <- split_df_into_settlements(df)

  # Using walk because we only want the side effects
  purrr::walk(split_settlements, write_cQuant_file)
}

compute_hourly_shape_profiles <- function(df) {
  normalized_hourly_shape_df <- df |>

    # Add an hour and day of week to dataframe
    dplyr::mutate(
      DayOfWeek = lubridate::wday(Date),
      Hour = lubridate::hour(Date)
    ) |>

    # Group data up and calculate the average price among these groups
    dplyr::group_by(SettlementPoint, Month, DayOfWeek, Hour) |>
    dplyr::summarize(AverageHourlyPrice = mean(Price), .groups = "drop_last") |>

    # Normalize the prices by dividing by the sum of each hourly price (within its group)
    dplyr::mutate(
      Price = AverageHourlyPrice / sum(AverageHourlyPrice)
    ) |>

    # Select the columns we care about
    dplyr::select(SettlementPoint, Month, DayOfWeek, Hour, Price) |>

    # Add an hour to account for cQuant hourly variables starting at 1
    dplyr::mutate(Hour = Hour + 1) |>

    # Actually take each hour and create a separate column for that hour
    tidyr::pivot_wider(
      names_from = Hour,
      values_from = Price,
      names_prefix = "X",
      id_cols = c(Month, DayOfWeek, SettlementPoint)
    )
  return(normalized_hourly_shape_df)
}


hourly_shape_write_fn <- function(df) {
  # First, extract the settlement point name
  settlementPoint <- as.character(unique(df["SettlementPoint"]))

  # Then, create the filename
  filename = paste(
    c(
      "output/hourlyShapeProfiles/profile_",
      settlementPoint,
      ".csv"
    ),
    collapse = ""
  )

  # Finally, write the CSV
  readr::write_csv(df, filename)
}
write_hourly_shape_profiles <- function(df) {
  settlement_splits <- df |>
    # Group into settlements and split into a list of each settlement point
    dplyr::group_by(SettlementPoint) |>
    dplyr::group_split()

  purrr::walk(settlement_splits, hourly_shape_write_fn)
}
