library(readr)
library(dplyr)
library(janitor)
library(lubridate)

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
  df <- readr::read_csv(all_files)

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
