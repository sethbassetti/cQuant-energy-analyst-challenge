library(stringr)
library(ggplot2)
library(lubridate)
library(dplyr)
library(ggbump)

#' Plots the average monthly prices as a line plot for different settlement points
#'
#' Filters the dataset by either settlement hubs or load zones, then plots the
#' average monthly price over all time, stratified by settlement type
#' @param df The dataframe with average monthly prices
#' @param settlement_prefix character, either HB or LZ, indicating what type of settlements to plot
plot_avg_monthly <- function(df, settlement_prefix) {
  # First, filter out the settlements we are looking for, and create a Date field
  df <- df |>
    dplyr::filter(stringr::str_starts(SettlementPoint, settlement_prefix)) |>
    dplyr::mutate(Date = lubridate::make_date(Year, Month))

  # Use different settlement type for labels
  settlement_type <- if (settlement_prefix == "HB") {
    "Settlement Hubs"
  } else {
    "Load Zones"
  }

  mean_plot <- df |>
    ggplot(aes(x = Date, y = AveragePrice, color = SettlementPoint)) +
    geom_line() +
    labs(
      title = paste(
        c("Average Monthly Price for ", settlement_type),
        collapse = ""
      ),
      x = "Date",
      y = "Average Price (USD)",
      color = settlement_type
    ) +

    # Nicely scale date so it appears starting at the beginning in increments of 6 months
    scale_x_date(breaks = seq(min(df$Date), max(df$Date), by = "6 months")) +

    # Give the y axis more ticks
    scale_y_continuous(n.breaks = 5)

  return(mean_plot)
}

#' Plots the compared average volatility between settlement hubs
#'
#' Uses a bump plot to compare hourly volatility per year between different settlement hubs
#' @param df The dataframe with hourly volatility data
plot_hourly_volatility <- function(df) {
  volatility_plot <- df |>
    ggplot(aes(
      x = Year,
      y = HourlyVolatility,
      color = SettlementPoint
    )) +
    geom_point(size = 3) +
    ggbump::geom_bump(
      data = df |>
        dplyr::filter(!SettlementPoint == "HB_PAN"),
      linewidth = 1.5
    ) +
    labs(
      title = "Compared Hourly Volatility between Settlement Hubs from 2016-2019",
      x = "Year",
      y = "Hourly Volatility",
      color = "Settlement Hub"
    )

  return(volatility_plot)
}
